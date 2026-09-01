// Morpho CreateMarket signature: event CreateMarket(Id indexed id, MarketParams marketParams);
// topic0: 0xeeaa9e6f2b0bbff2c3848b53db7b93809e5f7623351d5cdcb68470a6d1aebcc4
const CREATE_MARKET_TOPIC_0 = "0xeeaa9e6f2b0bbff2c3848b53db7b93809e5f7623351d5cdcb68470a6d1aebcc4";

// Extract config
let rpcUrl = process.env.ETHERLINK_MAINNET_RPC_URL || "https://node.mainnet.etherlink.com";
let wxtz = "0xc9B53AB2679f573e480d01e0f49e2B5CFB7a3EAb";
let usdc = "0x796Ea11Fa2dD751eD01b53C372fFDB4AAa8f00F9";
let morphoAddress = process.env.MORPHO_ADDRESS;
let approvedMarketId = process.env.APPROVED_MARKET_ID;

async function fetchLogs(rpc, address, fromBlock, toBlock) {
    const payload = {
        jsonrpc: "2.0",
        method: "eth_getLogs",
        params: [{
            address: address,
            fromBlock: fromBlock,
            toBlock: toBlock,
            topics: [CREATE_MARKET_TOPIC_0]
        }],
        id: 1
    };

    const res = await fetch(rpc, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
    });

    if (!res.ok) {
        throw new Error(`RPC returned status ${res.status}`);
    }
    const data = await res.json();
    if (data.error) {
        throw new Error(`RPC error: ${JSON.stringify(data.error)}`);
    }
    return data.result;
}

async function getLatestBlock(rpc) {
    const res = await fetch(rpc, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ jsonrpc: "2.0", method: "eth_blockNumber", params: [], id: 1 })
    });
    const data = await res.json();
    return parseInt(data.result, 16);
}

function parseAddress(hexStr) {
    // hexStr represents a 32-byte (64-character) hex word. The 20-byte (40-char) address
    // is right-aligned. Slicing at index 24 (64-40) grabs the last 40 chars.
    return "0x" + hexStr.slice(24);
}

async function run() {
    if (!morphoAddress) {
        console.warn("MORPHO_ADDRESS is not set. Exiting.");
        return;
    }

    try {
        const latestBlock = await getLatestBlock(rpcUrl);
        const fromBlock = "0x" + Math.max(0, latestBlock - 100).toString(16); // Reduced to last 100 blocks to avoid block range error
        const toBlock = "latest";

        console.log(`Checking Morpho ${morphoAddress} on ${rpcUrl} for CreateMarket logs...`);
        const logs = await fetchLogs(rpcUrl, morphoAddress, fromBlock, toBlock);

        if (logs.length === 0) {
            console.log("No CreateMarket events found in the recent blocks.");
            return;
        }

        for (const log of logs) {
            const marketId = log.topics[1];
            const data = log.data; // loanToken, collateralToken, oracle, irm, lltv

            // data is essentially 5 32-byte words: 0x + (5 * 64) chars
            const loanToken = parseAddress(data.slice(2, 66));
            const collateralToken = parseAddress(data.slice(66, 130));

            const involvesWxtz = loanToken.toLowerCase() === wxtz.toLowerCase() || collateralToken.toLowerCase() === wxtz.toLowerCase();
            const involvesUsdc = loanToken.toLowerCase() === usdc.toLowerCase() || collateralToken.toLowerCase() === usdc.toLowerCase();

            if (involvesWxtz || involvesUsdc) {
                if (marketId !== approvedMarketId) {
                    console.error(`[ALERT] Lookalike market detected!`);
                    console.error(`Market ID: ${marketId}`);
                    console.error(`Loan Token: ${loanToken}`);
                    console.error(`Collateral Token: ${collateralToken}`);
                } else {
                    console.log(`Approved market ${marketId} found.`);
                }
            }
        }

    } catch (e) {
        console.error("Error running duplicate market monitor:", e);
    }
}

run();
