// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {HonkVerifier} from "../src/Verifier.sol";
import {Rollup} from "../src/Rollup.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();

        // 1. Deploy the Verifier
        HonkVerifier verifier = new HonkVerifier();
        console.log("Verifier deployed at:", address(verifier));

        // 2. Deploy the Rollup with initial root
        // This is the old_root from the circuits/Prover.toml
        bytes32 initialRoot = bytes32(uint256(17885870545590202050793188371351306706632229787753813632294795864621092832986));
        Rollup rollup = new Rollup(address(verifier), initialRoot);
        console.log("Rollup deployed at:", address(rollup));

        vm.stopBroadcast();
    }
}