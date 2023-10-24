// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// ERC20 interface is imported
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract Escrow {
    
    event Deposit(uint indexed dealId, address indexed funder, address indexed tokenAddress, uint tokenAmount);
    // state variables

    // functions
    // takes dealId, funder, token address and token amount
    function deposit(uint dealId, address funder, address tokenAddress, uint tokenAmount) external {
        IERC20 token = IERC20(tokenAddress);
        
        // verify in some way (maybe not necessary)
        
        // call transferFrom on token contract
        require(token.transferFrom(funder, address(this), tokenAmount), "transferFrom failed");        

        //emit deposit event
        emit Deposit(dealId, funder, tokenAddress, tokenAmount);
    }

    // withdrawals should not work unless deal is verified or deal is canceled
    // once the deal is funded by party or counterparty, they must wait for either
    function withdraw(address tokenAddress, uint256 amount) public {
        // logic here

        // TODO: emit withdrawal event
    }
}


