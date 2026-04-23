/**
 * Invariant: The exchange rate cannot be manipulated to drain the vault.
 * "No Free Money" Property
 */
rule noInstantProfit(uint256 amount) {
    address user = msg.sender;
    require amount > 0;
    require totalAssets() > 0;

    uint256 balanceBefore = native_balance(user);

    // Sequence: Deposit then immediately Withdraw
    deposit(amount);
    uint256 sharesMinted = shares(user);
    withdraw(sharesMinted);

    uint256 balanceAfter = native_balance(user);

    // Assert that the user has NOT gained money through rounding
    assert balanceAfter <= balanceBefore, "Rounding error allowed profit!";
}