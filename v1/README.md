# ZK Mini Rollup (v1)

A minimal zero-knowledge rollup implementation that proves valid state transitions (token transfers) between accounts using ZK proofs. Built with [Noir](https://noir-lang.org/)

## Overview

This project demonstrates a ZK rollup where a prover can prove that a balance transfer between accounts is valid **without revealing** the account balances or transaction details. Only the old and new Merkle roots (state commitments) are public.

### How It Works

```
        [root]
       /      \
   hash(0,1)  hash(2,3)
   /    \      /    \
 bal[0] bal[1] bal[2] bal[3]
```

1. **Verify old state** — Recompute the Merkle root from private account balances using Poseidon (BN254) and assert it matches the public `old_root`.
2. **Validate transaction** — Check that indices are valid, the sender isn't sending to themselves, and the sender has sufficient balance.
3. **Compute new state** — Apply the transfer (subtract from sender, add to receiver).
4. **Verify new state** — Recompute the Merkle root from updated balances and assert it matches the public `new_root`.

### Circuit Inputs

| Input                     | Visibility | Type       | Description                              |
| ------------------------- | ---------- | ---------- | ---------------------------------------- |
| `old_root`                | Public     | Field      | Merkle root before the transfer          |
| `new_root`                | Public     | Field      | Merkle root after the transfer           |
| `from_index`              | Private    | u64        | Sender account index (0–3)               |
| `to_index`                | Private    | u64        | Receiver account index (0–3)             |
| `amount`                  | Private    | u64        | Transfer amount                          |
| `all_old_account_balance` | Private    | [Field; 4] | All account balances before the transfer |

## Project Structure

```
v1/
├── circuits/
│   ├── Nargo.toml          # Noir project config & dependencies
│   ├── Prover.toml          # Example prover inputs
│   └── src/
│       └── main.nr          # ZK circuit (Noir)
└── scripts/
    ├── package.json          # Node.js dependencies
    └── compute_root.js       # Helper to compute Merkle roots
```

## Prerequisites

- [Nargo](https://noir-lang.org/docs/getting_started/installation/) (Noir toolchain)
- [Node.js](https://nodejs.org/) (for helper scripts)

## Getting Started

### 1. Install script dependencies

```bash
cd v1/scripts
npm install
```

### 2. Compute Merkle roots for test inputs

```bash
node compute_root.js
```

This outputs `old_root` and `new_root` values. Paste them into `circuits/Prover.toml`.

### 3. Execute the circuit

```bash
cd v1/circuits
nargo execute
```

## Example

The default `Prover.toml` demonstrates a transfer of **30 tokens** from account **0** to account **1**:

| Account | Before | After |
| ------- | ------ | ----- |
| 0       | 100    | 70    |
| 1       | 50     | 80    |
| 2       | 200    | 200   |
| 3       | 75     | 75    |

## Dependencies

- **Noir circuit**: [noir-poseidon](https://github.com/chainlight-io/noir-poseidon) v0.1.1
- **Scripts**: [circomlibjs](https://www.npmjs.com/package/circomlibjs) v0.1.7
