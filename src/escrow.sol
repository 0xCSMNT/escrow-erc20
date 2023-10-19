// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;




contract Escrow {
    // state variables

    // functions
    function deposit(address tokenAddress, uint256 amount) public {
        // logic here
    }

    // withdrawals should not work unless deal is verified or deal is canceled
    // once the deal is funded by party or counterparty, they must wait for either
    function withdraw(address tokenAddress, uint256 amount) public {
        // logic here
    }
}
