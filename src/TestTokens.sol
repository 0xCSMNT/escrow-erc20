// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract JOHNToken is ERC20 {
    constructor() ERC20("JOHN", "JOHN") {
        _mint(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 100 * 10 ** decimals());
    }
}

contract MARYToken is ERC20 {
    constructor() ERC20("MARY", "MARY") {
        _mint(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 100 * 10 ** decimals());
    }
}

contract TokenDeployer {
    JOHNToken public john;
    MARYToken public mary;

    constructor() {
        john = new JOHNToken();
        mary = new MARYToken();
    }
}
