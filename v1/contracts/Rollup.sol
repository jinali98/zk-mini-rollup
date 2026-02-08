// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVerifier {
    function verify(bytes calldata proof, bytes32[] calldata publicInputs) external view returns (bool);
}

/**
 * @title Rollup
 * @notice Minimal ZK Rollup contract that manages state transitions
 * @dev Stores a single state root and verifies ZK proofs to update it
 */
contract Rollup {
    // The verifier contract that checks ZK proofs
    IVerifier public verifier;
    
    // Current state root (Merkle root of all account balances)
    bytes32 public currentRoot;
    
    // Events
    event StateUpdated(bytes32 indexed oldRoot, bytes32 indexed newRoot, uint256 timestamp);
    
    /**
     * @notice Initialize the rollup with a verifier and initial state root
     * @param _verifier Address of the proof verifier contract
     * @param _initialRoot Initial state root (Merkle root of initial balances)
     */
    constructor(address _verifier, bytes32 _initialRoot) {
        require(_verifier != address(0), "Invalid verifier address");
        verifier = IVerifier(_verifier);
        currentRoot = _initialRoot;
        
        emit StateUpdated(bytes32(0), _initialRoot, block.timestamp);
    }
    
    /**
     * @notice Update the rollup state with a proven state transition
     * @param proof The ZK proof bytes
     * @param oldRoot The previous state root (must match currentRoot)
     * @param newRoot The new state root after applying the transaction
     */
    function updateState(
        bytes calldata proof,
        bytes32 oldRoot,
        bytes32 newRoot
    ) external {
        // 1. Check that oldRoot matches current stored root
        require(oldRoot == currentRoot, "Old root mismatch");
        
        // 2. Prepare public inputs for the verifier
        // The circuit has 2 public inputs: oldRoot and newRoot
        bytes32[] memory publicInputs = new bytes32[](2);
        publicInputs[0] = oldRoot;
        publicInputs[1] = newRoot;
        
        // 3. Verify the proof
        bool isValid = verifier.verify(proof, publicInputs);
        require(isValid, "Invalid proof");
        
        // 4. Update the state root
        currentRoot = newRoot;
        
        emit StateUpdated(oldRoot, newRoot, block.timestamp);
    }
    
    /**
     * @notice Get the current state root
     * @return The current Merkle root representing rollup state
     */
    function getCurrentRoot() external view returns (bytes32) {
        return currentRoot;
    }
}