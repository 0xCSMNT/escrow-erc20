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
    address public constant DEV_ACCOUNT_0 =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant DEV_ACCOUNT_1 =
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

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

    ////////// HELPER FUNCTIONS //////////

    // Helper function to get deal details
    function getDealDetails(
        uint dealIndex
    ) internal view returns (Verifier.Deal memory deal) {
        (
            address party,
            address counterparty,
            address party_token,
            uint256 party_token_amount,
            address counterparty_token,
            uint256 counterparty_token_amount,
            bool party_funded,
            bool counterparty_funded,
            bool deal_canceled,
            bool deal_executed
        ) = verifier.deals(dealIndex);

        deal = Verifier.Deal({
            party: party,
            counterparty: counterparty,
            party_token: party_token,
            party_token_amount: party_token_amount,
            counterparty_token: counterparty_token,
            counterparty_token_amount: counterparty_token_amount,
            party_funded: party_funded,
            counterparty_funded: counterparty_funded,
            deal_canceled: deal_canceled,
            deal_executed: deal_executed
        });
    }

    ////////// TEST FUNCTIONS //////////

    // TEST VERIFIER ADDRESS ON ESCROW
    function testVeriferAddressOnEscrow() public {
        assertEq(
            escrow.viewVerifierAddress(),
            address(verifier),
            "Verifer address mismatch"
        );
        console.log("[IN TEST] Verifier address: ", address(verifier));
        console.log(
            "[IN TEST] Verifier address on Escrow contract: ",
            escrow.viewVerifierAddress()
        );
    }

    // TEST BALANCE OF TOKENS FOR USER ACCOUNTS
    function testAccountBalancesForDummyTokens() public {
        assertEq(
            mockLink.balanceOf(DEV_ACCOUNT_0),
            TOKEN_MINT_BALANCE,
            "incorrect LINK balance for dev account 0"
        );
        assertEq(
            mockUni.balanceOf(DEV_ACCOUNT_1),
            TOKEN_MINT_BALANCE,
            "incorrect UNI balance for dev account 1"
        );

        console.log( // dev account 0 should have 100 mLINK
            "[IN TEST] Dev Account 0 LINK balance: ",
            mockLink.balanceOf(DEV_ACCOUNT_0)
        );
        console.log( // dev account 1 should have 100 mUNI
            "[IN TEST] Dev Account 1 UNI balance: ",
            mockUni.balanceOf(DEV_ACCOUNT_1)
        );
    }

    // createDeal()
    // 1. first test 1 user can create a deal
    // 2. then test both users can create a deal
    // 3. create helper function so you can create an arbitrary number of deals

    // TEST USER 0 CREATES A DEAL
    function testDevAccount0CanCreateADeal() public {
        // Arrange
        vm.startPrank(DEV_ACCOUNT_0);
        verifier.createDeal(
            DEV_ACCOUNT_1,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT
        );
        vm.stopPrank();

        Verifier.Deal memory deal = getDealDetails(0);

        // Assert that the deal was created correctly
        assertEq(deal.party, DEV_ACCOUNT_0, "incorrect party address");
        assertEq(
            deal.counterparty,
            DEV_ACCOUNT_1,
            "incorrect counterparty address"
        );
        assertEq(
            deal.party_token,
            address(mockLink),
            "incorrect party token address"
        );
        assertEq(
            deal.party_token_amount,
            TOKEN_TRANSFER_AMOUNT,
            "incorrect party token amount"
        );
        assertEq(
            deal.counterparty_token,
            address(mockUni),
            "incorrect counterparty token address"
        );
        assertEq(
            deal.counterparty_token_amount,
            TOKEN_TRANSFER_AMOUNT,
            "incorrect counterparty token amount"
        );
        assertFalse(deal.party_funded, "incorrect party funded status");
        assertFalse(
            deal.counterparty_funded,
            "incorrect counterparty funded status"
        );
        assertFalse(deal.deal_canceled, "incorrect deal canceled status");
        assertFalse(deal.deal_canceled, "incorrect deal executed status");

        // TODO: check deal event emited
    }

    // TODO: TEST USER 1 CAN CREATE A DEAL AFTER USER 0 HAS CREATED A DEAL

    // fundDeal() TESTS    

    // TEST USER 0 CAN FUND A DEAL
    function testUser0CanFundDeal() public {
        // Arrange - set up the deal
        vm.startPrank(DEV_ACCOUNT_0);
        verifier.createDeal(
            DEV_ACCOUNT_1,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT
        );

        // Act - approve and fund the deal
        mockLink.approve(address(escrow), TOKEN_TRANSFER_AMOUNT);
        verifier.fundDeal(0);
        vm.stopPrank();

        // Assert - check the deal was funded correctly
        // check balances of escrow and user
        assertEq(
            mockLink.balanceOf(address(escrow)),
            TOKEN_TRANSFER_AMOUNT,
            "incorrect escrow balance"
        );
        assertEq(
            mockLink.balanceOf(DEV_ACCOUNT_0),
            TOKEN_MINT_BALANCE - TOKEN_TRANSFER_AMOUNT,
            "incorrect user balance"
        );

        // check status of deal using helper function
        Verifier.Deal memory deal = getDealDetails(0);

        assertTrue(deal.party_funded, "Deal not marked as funded by the party");
        assertFalse(
            deal.counterparty_funded,
            "Deal incorrectly marked as funded by the counterparty"
        );
        assertFalse(deal.deal_canceled, "Deal incorrectly marked as canceled");
        assertFalse(deal.deal_executed, "Deal incorrectly marked as executed");

        // Verifier.Deal memory deal = getDealDetails(0);
        // assertTrue(deal.partyFunded, "Deal not marked as funded by the party");
    }

    // TODO: FUNCTIONS TO TEST
    // partyVerifiesAndExecutes()
    // counterpartyVerifiesAndExecutes()
    // executeSwap()
    // checkDealStatus()
    // cancelDeal()
    // withdraw()
}
