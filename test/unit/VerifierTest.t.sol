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
    uint256 public constant TOKEN_MINT_BALANCE = 100;
    address public constant DEV_ACCOUNT_0 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant DEV_ACCOUNT_1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    
    // VARIABLES
    uint256 public expectedLinkBalance;
    uint256 public expectedUniBalance;


    // SETUP FUNCTION 
    function setUp() external {
        DeployContracts deployer = new DeployContracts();
        deployer.run();

        // Initialize the deployed contracts
        escrow = deployer.escrow();
        verifier = deployer.verifier();
        mockLink = deployer.mockLink();
        mockUni = deployer.mockUni();

        // Set expected balances using decimals
        expectedLinkBalance = TOKEN_MINT_BALANCE * (10 ** uint256(mockLink.decimals()));
        expectedUniBalance = TOKEN_MINT_BALANCE * (10 ** uint256(mockUni.decimals()));
    }

    // TEST FUNCTIONS

    // test verifier address set correctly
    function testVeriferAddressOnEscrow() public {
        address escrowVerifierAddress = escrow.viewVerifierAddress();
        address verifierAddress = address(verifier);
        assertEq(escrowVerifierAddress, verifierAddress, "Verifer address mismatch");
        console.log("[IN TEST] Verifier address: ", verifierAddress);
        console.log("[IN TEST] Verifier address on Escrow contract: ", escrowVerifierAddress);
        
    }

    // test balances of tokens for user accounts
    // dev account 0 should have 100e18 mLINK
    // dev account 1 should have 100e18 mUNI
    function testAccountBalancesForDummyTokens() public {
        
        // dev account addresses
        address devAccount0 = DEV_ACCOUNT_0;
        address devAccount1 = DEV_ACCOUNT_1;

        // balances of dev accounts
        uint256 devAccount0LinkBalance = mockLink.balanceOf(devAccount0);
        uint256 devAccount1UniBalance = mockUni.balanceOf(devAccount1);
        console.log("[IN TEST] Dev Account 0 LINK balance: ", devAccount0LinkBalance);
        console.log("[IN TEST] Dev Account 1 UNI balance: ", devAccount1UniBalance);

        // test balances
        assertEq(devAccount0LinkBalance, expectedLinkBalance, "incorrect LINK balance for dev account 0");
        assertEq(devAccount1UniBalance, expectedUniBalance, "incorrect UNI balance for dev account 1");
        
    }

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