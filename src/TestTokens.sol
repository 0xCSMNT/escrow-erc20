// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockLinkToken is ERC20 {
    constructor() ERC20("Mock Chainlink Token", "mLINK") {
        _mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 100); // Dev Account 0
    }
}

contract MockUniToken is ERC20 {
    constructor() ERC20("Mock Uniswap Token", "mUNI") {
        _mint(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 100); // Dev Account 1
    }
}

contract MockTokenDeployer {
    MockLinkToken public mockLink;
    MockUniToken public mockUni;

    constructor() {
        mockLink = new MockLinkToken();
        mockUni = new MockUniToken();
    }
}
