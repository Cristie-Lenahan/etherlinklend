// SPDX-License-Identifier: GPL-2.0-or-later OR BUSL-1.1
pragma solidity 0.8.24;

/* solhint-disable quotes */

import {ShadownetScript} from "./ShadownetScript.sol";
import {console2} from "forge-std/console2.sol";

contract RecordShadownetDeployment is ShadownetScript {
    function run() external onlyShadownet returns (string memory runPath) {
        _logHeader("06_RecordDeployment");

        string memory runId = vm.envOr("SHADOWNET_RUN_ID", string("00000000-000000"));
        string memory branchName = vm.envOr("GIT_BRANCH", string("TODO"));
        string memory commit = vm.envOr("GIT_COMMIT", string("TODO"));
        string memory upstreamMorpho = vm.envOr("UPSTREAM_MORPHO_BLUE_COMMIT", string("TODO"));
        address deployer = _envAddressOrZero("DEPLOYER_ADDRESS");
        address morpho = _envAddressOrZero("SHADOWNET_MORPHO");
        address loanToken = _envAddressOrZero("SHADOWNET_LOAN_TOKEN");
        address collateralToken = _envAddressOrZero("SHADOWNET_COLLATERAL_TOKEN");
        address oracle = _envAddressOrZero("SHADOWNET_ORACLE");
        address irm = _envAddressOrZero("SHADOWNET_IRM");
        string memory marketId = vm.envOr("SHADOWNET_MARKET_ID", string("TODO"));

        runPath = string.concat("deployments/etherlink-shadownet/runs/", runId, "-shadownet.json");
        string memory json = _artifactJson(
            branchName, commit, upstreamMorpho, deployer, morpho, loanToken, collateralToken, oracle, irm, marketId
        );
        string memory latestMd = _latestMarkdown(commit, morpho, loanToken, collateralToken, oracle, irm, marketId);

        vm.writeFile(runPath, json);
        vm.writeFile("deployments/etherlink-shadownet/latest.json", json);
        vm.writeFile("deployments/etherlink-shadownet/latest.md", latestMd);

        console2.log("artifact", runPath);
    }

    function _artifactJson(
        string memory branchName,
        string memory commit,
        string memory upstreamMorpho,
        address deployer,
        address morpho,
        address loanToken,
        address collateralToken,
        address oracle,
        address irm,
        string memory marketId
    ) internal pure returns (string memory) {
        return string.concat(
            "{\n",
            '  "status": "draft",\n',
            '  "network": {"name": "Etherlink Shadownet Testnet", "chainId": 127823, "rpcEnv": "ETHERLINK_SHADOWNET_RPC_URL", "explorer": "https://shadownet.explorer.etherlink.com"},\n',
            '  "repo": {"commit": "',
            commit,
            '", "branch": "',
            branchName,
            '", "dirty": null, "upstreamMorphoBlueCommit": "',
            upstreamMorpho,
            '"},\n',
            '  "deployer": {"address": "',
            vm.toString(deployer),
            '", "balanceBefore": "TODO", "balanceAfter": "TODO"},\n',
            '  "contracts": [\n',
            '    {"name": "Morpho", "address": "',
            vm.toString(morpho),
            '", "constructorArgs": ["TEST_MARKET_OWNER"], "verificationStatus": "TODO"},\n',
            '    {"name": "TestOnlyMockERC20 MOCK_LOAN", "address": "',
            vm.toString(loanToken),
            '", "constructorArgs": ["MOCK TEST Loan Token", "MOCK_LOAN", 18], "verificationStatus": "TODO"},\n',
            '    {"name": "TestOnlyMockERC20 MOCK_COLLATERAL", "address": "',
            vm.toString(collateralToken),
            '", "constructorArgs": ["MOCK TEST Collateral Token", "MOCK_COLLATERAL", 18], "verificationStatus": "TODO"},\n',
            '    {"name": "FixedRateIrm", "address": "',
            vm.toString(irm),
            '", "constructorArgs": [], "verificationStatus": "TODO"},\n',
            '    {"name": "TestOnlyFixedPriceOracle", "address": "',
            vm.toString(oracle),
            '", "constructorArgs": ["1e36", "MOCK_ORACLE_OWNER"], "verificationStatus": "TODO"}\n',
            "  ],\n",
            '  "market": {"loanToken": "',
            vm.toString(loanToken),
            '", "collateralToken": "',
            vm.toString(collateralToken),
            '", "oracle": "',
            vm.toString(oracle),
            '", "irm": "',
            vm.toString(irm),
            '", "lltv": "500000000000000000", "marketId": "',
            marketId,
            '"},\n',
            '  "transactions": [],\n',
            '  "verification": {"attempted": false, "successful": false, "notes": "TODO"},\n',
            '  "smokeTests": {"attempted": false, "successful": false, "results": []},\n',
            '  "warnings": ["Shadownet testnet only.", "Not production-ready.", "Do not reuse mock assets, mock oracle, or test parameters on mainnet."]\n',
            "}\n"
        );
    }

    function _latestMarkdown(
        string memory commit,
        address morpho,
        address loanToken,
        address collateralToken,
        address oracle,
        address irm,
        string memory marketId
    ) internal pure returns (string memory) {
        return string.concat(
            "# Latest Etherlink Shadownet Deployment\n\n",
            "Status: draft or operator-recorded.\n\n",
            "- Network: Etherlink Shadownet Testnet (`127823`)\n",
            "- Repo commit: `",
            commit,
            "`\n",
            "- Morpho: `",
            vm.toString(morpho),
            "`\n",
            "- MOCK_LOAN: `",
            vm.toString(loanToken),
            "`\n",
            "- MOCK_COLLATERAL: `",
            vm.toString(collateralToken),
            "`\n",
            "- Test-only oracle: `",
            vm.toString(oracle),
            "`\n",
            "- IRM: `",
            vm.toString(irm),
            "`\n",
            "- Market ID: `",
            marketId,
            "`\n\n",
            "This is Shadownet testnet only and is not production-ready.\n"
        );
    }
}
