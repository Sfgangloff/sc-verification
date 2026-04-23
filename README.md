# SecureVault: Formal Verification of Reentrancy Resistance

This project contains a Solidity smart contract and a corresponding formal proof in **Lean 4** demonstrating that the contract is mathematically safe from reentrancy attacks.

## Project Structure

* `Contracts/SecureVault.sol`: The Solidity implementation using the "Checks-Effects-Interactions" pattern.
* `ReentrancyProof/VaultModel.lean`: The formal mathematical model and proof of the contract's state consistency.
* `lakefile.toml`: Configuration for the Lean build system and Mathlib dependency.

## The Security Property

The core of this verification is the **Invariance Principle**. We define an `Invariant` where:
$$\sum (\text{User Balances}) = \text{Total Contract Liquidity}$$

A reentrancy attack succeeds if an attacker can drain more funds than their balance allows, which would break this equality. 



### The Proof
In `VaultModel.lean`, we prove the theorem `withdraw_is_reentrancy_safe`. This theorem guarantees that if the invariant holds before a withdrawal, it **must** hold after the withdrawal, even if the execution is "paused" during an external call. Because we update the state *before* the external interaction (the "Effects" step), any recursive call by an attacker will see the updated, reduced balance, preventing the exploit.

## Getting Started

### Prerequisites
1.  Install [elan](https://github.com/leanprover/elan) (the Lean version manager).
2.  Install [VS Code](https://code.visualstudio.com/) with the "Lean 4" extension.

### Installation & Build

1.  Clone the repository and enter the folder:
    ```bash
    cd ReentrancyProof
    ```

2.  Update dependencies and download the Mathlib cache:
    ```bash
    lake update
    lake exe cache get
    ```

3.  Build the project to verify the proofs:
    ```bash
    lake build
    ```

## Verification Details

The proof uses the following Lean tactics:
- `unfold`: To expand our definitions of state and invariants.
- `rw [List.sum_set]`: A Mathlib lemma to reason about how the sum of a list changes when one element is updated.
- `omega`: An automated tactic for handling the linear arithmetic of the balances.

If the `lake build` command completes without errors, the proof is machine-checked and valid.