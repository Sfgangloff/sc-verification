// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecureVault {
    mapping(address => uint256) public balances;

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount);
        // Effect before Interaction
        balances[msg.sender] -= _amount; 
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success);
    }
}