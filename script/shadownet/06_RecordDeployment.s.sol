// SPDX-License-Identifier: GPL-2.0-or-later OR BUSL-1.1
pragma solidity 0.8.24;

/* solhint-disable quotes */

import {ShadownetScript} from "./ShadownetScript.sol";
import {console2} from "forge-std/console2.sol";

contract RecordShadownetDeployment is ShadownetScript {
    function run() external onlyShadownet returns (string memory runPath) {
        _logHeader("06_RecordDeployment");

        string memory runId = vm.envOr("SHADOWNET_RUN_ID", string("00000000-000000"));

        string memory branchName = _getGitBranch();
        string memory commit = _getGitCommit();
        string memory upstreamMorpho = _getGitUpstreamMorphoCommit();

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

    function _getGitBranch() internal returns (string memory) {
        if (vm.envExists("GIT_BRANCH")) {
            return vm.envString("GIT_BRANCH");
        }
        string[] memory inputs = new string[](4);
        inputs[0] = "git";
        inputs[1] = "rev-parse";
        inputs[2] = "--abbrev-ref";
        inputs[3] = "HEAD";
        bytes memory res = vm.ffi(inputs);
        return _trimNewline(string(res));
    }

    function _getGitCommit() internal returns (string memory) {
        if (vm.envExists("GIT_COMMIT")) {
            return vm.envString("GIT_COMMIT");
        }
        string[] memory inputs = new string[](3);
        inputs[0] = "git";
        inputs[1] = "rev-parse";
        inputs[2] = "HEAD";
        bytes memory res = vm.ffi(inputs);
        string memory hexStr = vm.toString(res);
        return _substring(hexStr, 2, bytes(hexStr).length);
    }

    function _getGitUpstreamMorphoCommit() internal returns (string memory) {
        if (vm.envExists("UPSTREAM_MORPHO_BLUE_COMMIT")) {
            return vm.envString("UPSTREAM_MORPHO_BLUE_COMMIT");
        }
        string[] memory inputs = new string[](3);
        inputs[0] = "git";
        inputs[1] = "rev-parse";
        inputs[2] = "HEAD:lib/morpho-blue";
        bytes memory res = vm.ffi(inputs);
        string memory hexStr = vm.toString(res);
        return _substring(hexStr, 2, bytes(hexStr).length);
    }

    function _substring(string memory str, uint256 startIndex, uint256 endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for(uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function _trimNewline(string memory str) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        if (strBytes.length > 0 && strBytes[strBytes.length - 1] == 0x0a) {
            bytes memory newBytes = new bytes(strBytes.length - 1);
            for (uint i = 0; i < strBytes.length - 1; i++) {
                newBytes[i] = strBytes[i];
            }
            return string(newBytes);
        }
        return str;
    }
}
