// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IMPORTS FOR LOCAL ENVIRONMENT
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// IMPORTS FOR REMIX
// import {IERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.0/contracts/token/ERC20/IERC20.sol";

contract Escrow {

    // State variables
    address public admin;
    address public verifier;

    // Events
    event Deposit(uint indexed dealId, address indexed funder, address indexed tokenAddress, uint tokenAmount);
    event Withdrawal(uint indexed dealId, address indexed withdrawer, address indexed tokenAddress, uint tokenAmount);
    
    // Modifiers
    modifier onlyVerifier() {
        require(msg.sender == verifier, "Only Verifier can call this");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    // Constructor
    constructor() {
        admin = msg.sender;
        verifier = address(0);
    }

    // Set verifier
    function setVerifier(address _verifier) external onlyAdmin {
        verifier = _verifier;
    }

    // Deposit function
    function deposit(uint dealId, address funder, address tokenAddress, uint tokenAmount) external {
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(funder, address(this), tokenAmount), "transferFrom failed");
        emit Deposit(dealId, funder, tokenAddress, tokenAmount);
    }

    // Withdraw function
    function withdraw(uint dealId, address withdrawer, address tokenAddress, uint256 tokenAmount) external onlyVerifier {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(withdrawer, tokenAmount), "transfer failed");
        emit Withdrawal(dealId, withdrawer, tokenAddress, tokenAmount);
    }
}

