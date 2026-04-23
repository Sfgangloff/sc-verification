import Mathlib

structure VaultState where
  balances : List Nat
  total_liquidity : Nat

def Invariant (s : VaultState) : Prop :=
  s.balances.sum = s.total_liquidity

def apply_withdrawal (s : VaultState) (user_idx : Nat) (amt : Nat) : VaultState :=
  if h_idx : user_idx < s.balances.length then
    if s.balances.get ⟨user_idx, h_idx⟩ >= amt then
      { balances := s.balances.set user_idx (s.balances.get ⟨user_idx, h_idx⟩ - amt),
        total_liquidity := s.total_liquidity - amt }
    else s
  else s

theorem withdraw_is_reentrancy_safe
  (s : VaultState) (u : Nat) (a : Nat) :
  Invariant s → Invariant (apply_withdrawal s u a) :=
by
  intro h_inv
  unfold apply_withdrawal Invariant
  split_ifs with h_idx h_amt
  · -- successful withdrawal
    let x := s.balances.get ⟨u, h_idx⟩

    -- expand the modified sum
    have hsum :=
      List.sum_set s.balances u (x - a)

    have hsum' :
        (s.balances.set u (x - a)).sum =
          (s.balances.take u).sum +
          (x - a) +
          (s.balances.drop (u + 1)).sum := by
      simpa [h_idx] using hsum

    -- expand the original sum
    have h_orig :
        s.balances.sum =
          (s.balances.take u).sum +
          x +
          (s.balances.drop (u + 1)).sum := by
      have := List.sum_set s.balances u x
      have hset : s.balances.set u x = s.balances := by
        simp [x]
      simpa [h_idx, hset] using this

    -- core algebra, now easy
    let A := (s.balances.take u).sum
    let B := (s.balances.drop (u + 1)).sum

    have hcalc :
        A + (x - a) + B = s.balances.sum - a := by

      -- Step 1: reassociate
      have h₁ :
          A + (x - a) + B = A + ((x - a) + B) := by
        simp [Nat.add_assoc]

      -- Step 2: push subtraction across addition
      have h₂ :
          (x - a) + B = (x + B) - a := by
        -- Step 1: rewrite RHS into B + x - a
        have h₁ : (x + B) - a = B + x - a := by
          simp [Nat.add_comm]

        -- Step 2: apply add_sub_assoc to B + x
        have h₂' : B + x - a = B + (x - a) :=
          Nat.add_sub_assoc h_amt B

        -- Step 3: rearrange back
        calc
          (x - a) + B
              = B + (x - a) := by
                simp [Nat.add_comm]
          _ = B + x - a := by
                simpa using h₂'.symm
          _ = (x + B) - a := by
                simp [h₁]

      -- Step 3: lift under A +
      have h₃ :
          A + ((x - a) + B) = A + ((x + B) - a) := by
        simp [h₂]

      -- Step 4: move subtraction outward
      have h₄ :
          A + ((x + B) - a) = (A + (x + B)) - a := by
        -- IMPORTANT: apply lemma with (m := x + B), (n := A)
        have := Nat.add_sub_assoc (m := x + B) (k := a) (n := A) ?_
        · exact this.symm
        ·
          -- prove a ≤ x + B from h_amt : a ≤ x
          exact Nat.le_trans h_amt (Nat.le_add_right _ _)

      -- Step 5: reassociate
      have h₅ :
          (A + (x + B)) - a = (A + x + B) - a := by
        simp [Nat.add_assoc]

      -- combine everything
      have :
          A + (x - a) + B = (A + x + B) - a :=
        h₁.trans (h₃.trans (h₄.trans h₅))

      -- finish using h_orig
      simpa [h_orig] using this

    -- conclude
    have :
        (s.balances.set u (x - a)).sum =
          s.total_liquidity - a := by

      -- Step 1: reduce to balances.sum - a
      have h₀ :
          (s.balances.set u (x - a)).sum =
            s.balances.sum - a := by
        simpa [hsum', hcalc]

      -- Step 2: transport equality through subtraction
      have h₁ :
          s.balances.sum - a = s.total_liquidity - a :=
        congrArg (fun t => t - a) h_inv

      -- Step 3: conclude
      exact h₀.trans h₁

    exact this

  · exact h_inv
  · exact h_inv
