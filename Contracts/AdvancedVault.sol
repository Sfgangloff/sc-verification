// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract AdvancedVault {
    using Math for uint256;

    uint256 public totalShares;
    uint256 public totalAssets;
    mapping(address => uint256) public shares;

    /// @notice Deposit assets to get shares
    function deposit() public payable { // Remove the amount parameter if you're using msg.value
    require(msg.value > 0, "Must send ETH");
    
    uint256 sharesToMint;
    if (totalShares == 0) {
        sharesToMint = msg.value;
    } else {
        // totalAssets here should represent the balance BEFORE this deposit
        sharesToMint = (msg.value * totalShares) / (address(this).balance - msg.value);
    }
    
    shares[msg.sender] += sharesToMint;
    totalShares += sharesToMint;
    totalAssets += msg.value; // Explicitly track the ETH sent
}

    /// @notice Withdraw assets by burning shares
    function withdraw(uint256 _shareAmount) public {
        require(shares[msg.sender] >= _shareAmount, "Insufficient shares");
        
        uint256 _assetsToReturn = (_shareAmount * totalAssets) / totalShares;
        
        // CEI Pattern
        shares[msg.sender] -= _shareAmount;
        totalShares -= _shareAmount;
        totalAssets -= _assetsToReturn;

        (bool success, ) = msg.sender.call{value: _assetsToReturn}("");
        require(success, "Transfer failed");
    }
}