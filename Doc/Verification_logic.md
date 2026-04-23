# Formal Verification Analysis: SecureVault

## 1. Safety Property: Reentrancy Immunity
The contract is immune to reentrancy because it maintains the **State Invariant** during the external call.

### Logic Flow:
1. **Initial State ($S_0$):** `balances[user] = N`
2. **State Transition ($S_1$):** `balances[user]` is updated to `N - amount` *before* control flow is handed to `msg.sender`.
3. **External Call ($S_{ext}$):** If `msg.sender` attempts to re-enter `withdraw()`, the `require` statement checks the state at $S_1$.
4. **Result:** Since $S_1$ already reflects the deduction, the re-entry fails the check: `(N - amount) < amount`.

## 2. Mathematical Invariants
- **Solvency:** `total_assets >= sum(balances)`
- **Authorized Decrease:** `balance[i]` can only decrease if `msg.sender == i`.