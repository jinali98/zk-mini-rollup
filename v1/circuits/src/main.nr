use poseidon::poseidon;

fn main(
    //public inputs
    old_root: Field,
    new_root: Field,
    //private inputs
    from_index: u64,
    to_index: u64,
    amount: u64,
    all_old_account_balance: [Field; 4],
) {
    // verify old root is correct by re creating the merkle root from the old balances
    let h0_old = poseidon::bn254::hash_2([all_old_account_balance[0], all_old_account_balance[1]]);
    let h1_old = poseidon::bn254::hash_2([all_old_account_balance[2], all_old_account_balance[3]]);
    let computed_old_root = poseidon::bn254::hash_2([h0_old, h1_old]);

    assert(computed_old_root == old_root);

    // validate transaction indexes
    assert(from_index < 4);
    assert(to_index < 4);

    // validate not sending to yourself
    assert(from_index != to_index);

    // find from and to old balances
    let from_old_balance = if from_index == 0 {
        all_old_account_balance[0]
    } else if from_index == 1 {
        all_old_account_balance[1]
    } else if from_index == 2 {
        all_old_account_balance[2]
    } else {
        all_old_account_balance[3]
    };

    // let to_old_balance = if to_index == 0 {
    //     all_old_account_balance[0]
    // } else if to_index == 1 {
    //     all_old_account_balance[1]
    // } else if to_index == 2 {
    //     all_old_account_balance[2]
    // } else {
    //     all_old_account_balance[3]
    // };

    // validate from has enough balance
    assert((from_old_balance as u64) >= amount);

    // compute new balances

    let mut new_balances = [0; 4];

    for i in 0..4 {
        let i: u64 = i as u64;

        let mut balance = all_old_account_balance[i as u32];

        if i == (from_index) {
            balance = balance - (amount as Field);
        }

        if i == to_index {
            balance = balance + (amount as Field);
        }

        new_balances[i as u32] = balance;
    }

    // build the new merkle root
    let h0_new = poseidon::bn254::hash_2([new_balances[0], new_balances[1]]);
    let h1_new = poseidon::bn254::hash_2([new_balances[2], new_balances[3]]);
    let computed_new_root = poseidon::bn254::hash_2([h0_new, h1_new]);

    // verify the new root is correct

    assert(computed_new_root == new_root);
}
