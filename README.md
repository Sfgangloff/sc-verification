# Formal Methods Portfolio: Smart Contract Security

This repository demonstrates the application of **Formal Specification** and **Hoare Logic** to a Solidity vault.

### Contents
- `SecureVault.sol`: Implementation using the Checks-Effects-Interactions (CEI) pattern.
- `SecureVault.spec`: Formal rules written in CVL (Certora Verification Language) to define safety and liveness properties.
- `Verification_Logic.md`: A breakdown of the state-machine transitions and proof of reentrancy resistance.

### Tools & Methodology
- **Pattern:** Checks-Effects-Interactions.
- **Verification approach:** Property-based testing and manual inductive proof of state invariants.