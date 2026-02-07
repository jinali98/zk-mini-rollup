# ZK Mini Rollup

**My Learning Journey: Building ZK Rollups from Scratch**

This is my personal project where I'm learning how zero-knowledge rollups work by implementing them from scratch. I'm documenting everything as I go, building from simple examples (v1) toward more production-ready implementations (v2).

## Project Versions

### v1 - Educational Implementation

A minimal, easy-to-understand ZK rollup implementation designed for learning. This version demonstrates core concepts with a simplified 4-account Merkle tree

See [`v1/README.md`](v1/README.md) for detailed documentation.

### v2 - Production-Grade (Planned)

A scalable ZK rollup implementation featuring proper state management, withdrawal mechanisms, fraud proofs, and complete operator infrastructure. This version will demonstrate real-world patterns and optimizations used in production systems.

## What is a ZK Rollup?

Zero-knowledge rollups are Layer 2 scaling solutions that dramatically reduce transaction costs on Ethereum by executing transactions off-chain and proving their correctness on-chain using cryptographic proofs.

### The Core Problem

Executing every transaction directly on Ethereum is expensive. Each transaction requires gas fees, and complex operations can cost hundreds or thousands of dollars. As Ethereum adoption grows, this becomes a significant barrier to scalability.

### The Solution

Instead of executing transactions on Ethereum, ZK rollups execute them off-chain and only submit a cryptographic proof to Ethereum that proves the transactions were processed correctly. This proof is tiny (typically a few hundred bytes) regardless of how many transactions it covers.

### How It Works - The Complete Flow

#### 1. State Storage

Ethereum stores a single hash (32 bytes) called the **Merkle root**. This root represents the entire rollup state, which could include thousands or millions of user balances, accounts, and other state data. All the actual state data is stored off-chain by the rollup operator.

#### 2. Users Submit Transactions

When users want to interact with the rollup (e.g., send tokens), they submit transactions to the rollup operator off-chain. The operator collects many transactions together in batches.

#### 3. Operator Processes Off-Chain

The operator maintains the full Merkle tree containing all account balances and state. When processing a batch of transactions:

- The operator executes each transaction against the current state
- Balances are updated (e.g., Alice: 100 → 70, Bob: 50 → 80)
- A new Merkle root is computed from the updated state
- The state transitions from `old_root` → `new_root`

#### 4. Operator Generates ZK Proof

The operator generates a zero-knowledge proof that cryptographically proves:

- The old root was valid (computed correctly from the previous state)
- All transactions in the batch were valid (sufficient balances, valid signatures, etc.)
- The new root was computed correctly from the updated state
- The state transition follows all the rules of the rollup

Crucially, this proof reveals **nothing** about individual account balances, transaction amounts, or other private details. It only proves that a valid state transition occurred.

#### 5. Operator Submits to Ethereum

The operator submits to an Ethereum smart contract:

- The ZK proof (small, typically ~300 bytes)
- The old root (already stored on-chain)
- The new root (what we're updating to)
- Compressed transaction data (for data availability, if needed)

#### 6. Smart Contract Verifies

The Ethereum smart contract:

- Verifies that the current stored root matches the submitted old root
- Verifies the ZK proof cryptographically
- If both checks pass, updates the stored root to the new root

#### 7. State Update Complete

The state root on Ethereum is now updated. All the transactions in the batch have been processed, balances have changed, but Ethereum never learned the individual account balances or transaction details. It only knows that a valid state transition occurred.

### The Magic: Compression and Cost Savings

**What gets compressed:**

- Processing 100 transactions with balances, Merkle proofs, and signatures directly on Ethereum would require megabytes of data and cost thousands of dollars in gas fees
- With ZK rollups, this becomes one proof plus two roots: approximately 400 bytes total

**Cost savings:**

- Processing 100 transactions directly on Ethereum: potentially $10,000+ in gas fees
- Processing 100 transactions in a rollup + posting proof: potentially $100 in gas fees
- **100x cheaper** (or more, depending on transaction complexity)

### Security Guarantees

The mathematical properties of zero-knowledge proofs guarantee:

- **Correctness**: If the proof verifies, the state transition is mathematically guaranteed to be valid
- **Impossibility of cheating**: If the operator tries to cheat (steal funds, process invalid transactions, or compute incorrect roots), the proof will fail to verify
- **User safety**: Users can always exit the rollup by submitting a Merkle proof of their account state to the Ethereum contract
- **Trust minimization**: Users don't need to trust the operator—they only need to trust the cryptographic proof system

## Why I'm Building This

I'm building this project to deeply understand how zero-knowledge rollups work under the hood. While there's plenty of high-level documentation about ZK rollups, I wanted to actually implement one myself to truly grasp the internals—from how Merkle trees represent state, to how ZK proofs verify state transitions, to the complete architecture.

Zero-knowledge rollups are fascinating technology that could revolutionize blockchain scaling, and I believe the best way to understand them is by building one. If you're on a similar learning journey, I hope this project helps you understand these concepts too!
