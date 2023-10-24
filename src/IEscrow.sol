// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEscrow {
    function deposit(
        uint dealId,
        address funder,
        address tokenAddress,
        uint tokenAmount
    ) external;

    function withdraw(address tokenAddress, uint amount) external;
}
