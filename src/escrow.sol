// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// ERC20 interface is imported
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract Escrow {
    // state variables

    // functions
    // takes dealId, funder, token address and token amount
    function deposit(uint dealId, address funder, address tokenAddress, uint tokenAmount) external {
        // verify in some way (maybe not necessary)
        // call transferFrom on token contract

        // TODO: emit deposit event
    }

    // withdrawals should not work unless deal is verified or deal is canceled
    // once the deal is funded by party or counterparty, they must wait for either
    function withdraw(address tokenAddress, uint256 amount) public {
        // logic here

        // TODO: emit withdrawal event
    }
}


