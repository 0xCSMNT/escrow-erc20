// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Verifier} from "src/verifier.sol";
import {Escrow} from "src/escrow.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {DeployContracts} from "script/DeployContracts.s.sol";
import {MockLinkToken} from "src/TestTokens.sol";
import {MockUniToken} from "src/TestTokens.sol";

contract VerifierTest is StdCheats, Test {
    Verifier public verifier;
    Escrow public escrow;
    MockLinkToken public mockLink;
    MockUniToken public mockUni;

    // CONSTANTS
    // like: uint constant public ZERO = 0;

    // SETUP FUNCTION 
    function setUp() external {
        DeployContracts deployer = new DeployContracts();
        deployer.run();

        // Initialize the deployed contracts
        escrow = deployer.escrow();
        verifier = deployer.verifier();
        mockLink = deployer.mockLink();
        mockUni = deployer.mockUni();
    }

    // TEST FUNCTIONS

    // test verifier address set correctly
    function testVeriferAddressOnEscrow() public {
        address escrowVerifierAddress = escrow.viewVerifierAddress();
        address verifierAddress = address(verifier);
        assertEq(escrowVerifierAddress, verifierAddress);
        console.log("[IN TEST] Verifier address: ", verifierAddress);
        console.log("[IN TEST] Verifier address on Escrow contract: ", escrowVerifierAddress);
        
    }

    // test balances of tokens for user accounts

    // createDeal()
    // fundDeal()
    // partyVerifiesAndExecutes()
    // counterpartyVerifiesAndExecutes()
    // executeSwap()
    // checkDealStatus()
    // cancelDeal()
    // withdraw()
    
// first: simple tests 
    // go through functions in verifer
// second: complex tests
    // create erc20s and users and fund them
    // do withdrawals and deposits based on user state

// 1. Unit Tests
// 2. Integration Tests
// 3. Forked Tests (sepolia)
// 4. Staging Tests (sepolia)
}