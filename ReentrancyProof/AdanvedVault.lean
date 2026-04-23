import Mathlib.Data.Nat.Basic

structure VaultState where
  totalAssets : ℕ
  totalShares : ℕ
  userShares  : ℕ
  inv : userShares ≤ totalShares

/--
  Definition of the withdrawal transition.
-/
def withdraw (s : VaultState) (amount : ℕ) (_h_enough : amount ≤ s.userShares) : VaultState :=
  let assetsToReturn := (amount * s.totalAssets) / s.totalShares
  {
    totalAssets := s.totalAssets - assetsToReturn,
    totalShares := s.totalShares - amount,
    userShares  := s.userShares - amount,
    inv := Nat.sub_le_sub_right s.inv amount
  }

/--
  Theorem: The 'No-Free-Lunch' property.
-/
theorem assets_returned_bounded (s : VaultState) (amount : ℕ) (h : amount ≤ s.userShares) :
  (amount * s.totalAssets) / s.totalShares ≤ s.totalAssets := by
  let { totalAssets := ta, totalShares := ts, userShares := us, inv := invariant } := s
  by_cases h_ts : ts = 0
  · have h_us : us = 0 := Nat.eq_zero_of_le_zero (h_ts ▸ invariant)
    have h_am : amount = 0 := Nat.eq_zero_of_le_zero (h_us ▸ h)
    rw [h_am]
    simp
  · apply Nat.div_le_of_le_mul
    -- Goal: amount * ta ≤ ts * ta
    let h_amt_le_ts : amount ≤ ts := Nat.le_trans h invariant
    -- Fix: In your version, it expects (multiplier) then (proof)
    exact Nat.mul_le_mul_right ta h_amt_le_ts

/--
  Theorem: Liveness/Solvency.
-/
theorem withdrawal_preserves_total_shares (s : VaultState) (amount : ℕ) (h : amount ≤ s.userShares) :
  (withdraw s amount h).totalShares = s.totalShares - amount := by
  rfl

/--
  Definition of the deposit transition.
  Reflects the 'Fixed' Solidity code: shares minted depend on msg.value.
-/
def deposit (s : VaultState) (value : ℕ) : VaultState :=
  let sharesToMint :=
    if s.totalShares = 0 then value
    else (value * s.totalShares) / s.totalAssets
  {
    totalAssets := s.totalAssets + value,
    totalShares := s.totalShares + sharesToMint,
    userShares  := s.userShares + sharesToMint,
    -- Lean sees the goal as: (s.userShares + sharesToMint) ≤ (s.totalShares + sharesToMint)
    inv := Nat.add_le_add_right s.inv sharesToMint
  }

/--
  Theorem: Deposit Safety.
  Proves that after any deposit, the user's new share balance
  is still bounded by the new total supply.
-/
theorem deposit_preserves_invariant (s : VaultState) (value : ℕ) :
  (deposit s value).userShares ≤ (deposit s value).totalShares := by
  -- Use 'deposit.inv' which is the name Lean gives to the
  -- invariant proof attached to the result of the function.
  exact (deposit s value).inv
