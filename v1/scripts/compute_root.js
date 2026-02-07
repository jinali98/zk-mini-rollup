const { buildPoseidon } = require("circomlibjs");

async function computeRoots() {
  const poseidon = await buildPoseidon();
  const F = poseidon.F;

  // Old state
  const oldBalances = [100, 50, 200, 75];
  const h0_old = poseidon([oldBalances[0], oldBalances[1]]);
  const h1_old = poseidon([oldBalances[2], oldBalances[3]]);
  const oldRoot = poseidon([h0_old, h1_old]);

  // Transaction: account 0 sends 30 to account 1
  const newBalances = [70, 80, 200, 75];
  const h0_new = poseidon([newBalances[0], newBalances[1]]);
  const h1_new = poseidon([newBalances[2], newBalances[3]]);
  const newRoot = poseidon([h0_new, h1_new]);

  console.log("Copy these values into Prover.toml:\n");
  console.log(`old_root = "${F.toString(oldRoot)}"`);
  console.log(`new_root = "${F.toString(newRoot)}"`);
}

computeRoots().catch(console.error);
