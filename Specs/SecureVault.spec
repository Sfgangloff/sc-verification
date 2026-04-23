/**
 * Formal Specification for SecureVault
 */

// Rule: A user's balance must only change by the amount they withdraw.
rule integrityOfWithdrawal(uint256 amount) {
    address user = msg.sender;
    
    uint256 balanceBefore = balances(user);
    
    withdraw(amount);
    
    uint256 balanceAfter = balances(user);
    
    assert balanceAfter == balanceBefore - amount, "Post-condition: Balance must decrease by amount";
}

// Rule: No other user's balance should change during a withdrawal.
rule noSideEffects(address otherUser, uint256 amount) {
    require otherUser != msg.sender;
    
    uint256 balanceBefore = balances(otherUser);
    
    withdraw(amount);
    
    uint256 balanceAfter = balances(otherUser);
    
    assert balanceAfter == balanceBefore, "Isolation: Other user balances must remain invariant";
}