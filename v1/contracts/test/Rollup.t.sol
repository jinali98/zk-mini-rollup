// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {HonkVerifier} from "../src/Verifier.sol";
import {Rollup} from "../src/Rollup.sol";

contract RollupTest is Test {
    Rollup public rollup;
    HonkVerifier public verifier;
    bytes32 public initialRoot;

    function setUp() public {
        verifier = new HonkVerifier();
        initialRoot = bytes32(uint256(17885870545590202050793188371351306706632229787753813632294795864621092832986));
        rollup = new Rollup(address(verifier), initialRoot);
    }

    function test_InitialRoot() public view {
        assertEq(rollup.currentRoot(), initialRoot);
    }

    function test_RevertOnRootMismatch() public {
        bytes32 wrongRoot = bytes32(uint256(123));
        bytes32 newRoot = bytes32(uint256(456));
        vm.expectRevert("Old root mismatch");
        rollup.updateState("", wrongRoot, newRoot);
    }

    function test_RevertOnZeroVerifier() public {
        vm.expectRevert("Invalid verifier address");
        new Rollup(address(0), initialRoot);
    }
}