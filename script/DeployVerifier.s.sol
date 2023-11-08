// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Verifier} from "../src/verifier.sol";
import {Escrow} from "../src/escrow.sol";

contract DeployVerifier is Script {

    function run() external returns (Escrow, Verifier) {
        vm.startBroadcast();
        
        // Deploy Escrow contract and get address
        Escrow escrow = new Escrow();
        address escrowAddress = address(escrow);

        // Deploy Verifier contract and pass in Escrow address
        Verifier verifier = new Verifier(escrowAddress);
        escrow.setVerifier(address(verifier));
        
        vm.stopBroadcast();
        return (escrow, verifier);
    }
}




