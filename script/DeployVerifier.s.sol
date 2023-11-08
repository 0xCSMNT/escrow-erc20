// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {MockLinkToken} from "../src/TestTokens.sol";
import {MockUniToken} from "../src/TestTokens.sol";
import {Verifier} from "../src/Verifier.sol";
import {Escrow} from "../src/Escrow.sol";

contract DeployContracts is Script {

    function run() external {
        vm.startBroadcast();

        // Deploy the mock tokens
        MockLinkToken mockLink = new MockLinkToken();
        MockUniToken mockUni = new MockUniToken();

        // Deploy the Escrow and Verifier contracts
        Escrow escrow = new Escrow();
        Verifier verifier = new Verifier(address(escrow));
        
        // Set up the Escrow contract with the verifier
        escrow.setVerifier(address(verifier));

        vm.stopBroadcast();

        // Output the addresses of the deployed contracts
        console.log("MockLinkToken deployed at:", address(mockLink));
        console.log("MockUniToken deployed at:", address(mockUni));
        console.log("Escrow deployed at:", address(escrow));
        console.log("Verifier deployed at:", address(verifier));
    }
}





