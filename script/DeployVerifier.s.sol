// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Verifier} from "../src/verifier.sol";

contract DeployVerifier is Script {
    function run() external returns (Verifier) {
        vm.startBroadcast();
        Verifier verifier = new Verifier();
        vm.stopBroadcast();
        return verifier;
    }
}
