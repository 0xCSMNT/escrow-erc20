// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {MockLinkToken} from "../src/TestTokens.sol";
import {MockUniToken} from "../src/TestTokens.sol";
import {Verifier} from "../src/verifier.sol";
import {Escrow} from "../src/escrow.sol";

contract DeployContracts is Script {
    // Declare the contracts as public state variables
    MockLinkToken public mockLink;
    MockUniToken public mockUni;
    Escrow public escrow;
    Verifier public verifier;

    function run() external {
        vm.startBroadcast();

        // Deploy the mock tokens
        mockLink = new MockLinkToken();
        mockUni = new MockUniToken();

        // Deploy the Escrow and Verifier contracts
        escrow = new Escrow();
        verifier = new Verifier(address(escrow));
        
        // Set up the Escrow contract with the verifier
        escrow.setVerifier(address(verifier));

        vm.stopBroadcast();

        ////////// LOGS FOR DEBUGGING //////////

        // console.log("[IN DEPLOY] MockLinkToken deployed at:", address(mockLink));
        // console.log("[IN DEPLOY] MockUniToken deployed at:", address(mockUni));
        // console.log("[IN DEPLOY] Escrow deployed at:", address(escrow));
        // console.log("[IN DEPLOY] Verifier deployed at:", address(verifier));
    }
}





