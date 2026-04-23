// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecureVault
/// @notice A simple vault demonstrating the Checks-Effects-Interactions (CEI) pattern.
contract SecureVault {
    mapping(address => uint256) public balances;

    /// @notice Withdraws ether from the vault.
    /// @dev Satisfies the "Effect-before-Interaction" safety property.
    function withdraw(uint256 _amount) public {
        // 1. CHECK
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        // 2. EFFECT 
        // Note: Reducing balance before the call prevents reentrancy.
        balances[msg.sender] -= _amount; 

        // 3. INTERACTION
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}