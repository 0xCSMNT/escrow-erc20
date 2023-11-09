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
    uint256 public constant TOKEN_TRANSFER_AMOUNT = 10;
    address public constant DEV_ACCOUNT_0 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant DEV_ACCOUNT_1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

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

    ////////// TEST FUNCTIONS //////////

    // TEST VERIFIER ADDRESS ON ESCROW
    function testVeriferAddressOnEscrow() public {
        
        assertEq(escrow.viewVerifierAddress(), address(verifier), "Verifer address mismatch");
        console.log("[IN TEST] Verifier address: ", address(verifier));
        console.log("[IN TEST] Verifier address on Escrow contract: ", escrow.viewVerifierAddress());
        
    }

    // TEST BALANCE OF TOKENS FOR USER ACCOUNTS
    function testAccountBalancesForDummyTokens() public {

        assertEq(mockLink.balanceOf(DEV_ACCOUNT_0), TOKEN_MINT_BALANCE, "incorrect LINK balance for dev account 0");
        assertEq(mockUni.balanceOf(DEV_ACCOUNT_1), TOKEN_MINT_BALANCE, "incorrect UNI balance for dev account 1");

        // dev account 0 should have 100e18 mLINK
        // dev account 1 should have 100e18 mUNI

        console.log("[IN TEST] Dev Account 0 LINK balance: ", mockLink.balanceOf(DEV_ACCOUNT_0));
        console.log("[IN TEST] Dev Account 1 UNI balance: ", mockUni.balanceOf(DEV_ACCOUNT_1));
}

    // createDeal() 
    // 1. first test 1 user can create a deal
    // 2. then test both users can create a deal

    // TEST USER 0 CREATES A DEAL
    function testDevAccount0CanCreateADeal() public {
        vm.startPrank(DEV_ACCOUNT_0);
        verifier.createDeal(
            DEV_ACCOUNT_1,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT
        );
        vm.stopPrank();

        // Retrieve the deal details using tuple destructuring
        (
            address party,
            address counterparty,
            address partyToken,
            uint256 partyTokenAmount,
            address counterpartyToken,
            uint256 counterpartyTokenAmount,
            bool partyFunded,
            bool counterpartyFunded,
            bool dealCanceled,
            bool dealExecuted
        ) = verifier.deals(0);

        // Assert that the deal was created correctly
        assertEq(party, DEV_ACCOUNT_0, "incorrect party address");
        assertEq(counterparty, DEV_ACCOUNT_1, "incorrect counterparty address");
        assertEq(partyToken, address(mockLink), "incorrect party token address");
        assertEq(partyTokenAmount, TOKEN_TRANSFER_AMOUNT, "incorrect party token amount");
        assertEq(counterpartyToken, address(mockUni), "incorrect counterparty token address");
        assertEq(counterpartyTokenAmount, TOKEN_TRANSFER_AMOUNT, "incorrect counterparty token amount");
        assertEq(partyFunded, false, "incorrect party funded status");
        assertEq(counterpartyFunded, false, "incorrect counterparty funded status");
        assertEq(dealCanceled, false, "incorrect deal canceled status");
        assertEq(dealExecuted, false, "incorrect deal executed status");


        // check event emited
    }

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