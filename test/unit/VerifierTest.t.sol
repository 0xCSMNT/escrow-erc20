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

    // Helper Function: User x creates a deal 
    function createDealForTest(
        address party,
        address counterparty,
        address party_token,
        uint256 party_token_amount,
        address counterparty_token,
        uint256 counterparty_token_amount
    ) internal {
        vm.startPrank(party);
        verifier.createDeal(
            counterparty,
            party_token,
            party_token_amount,
            counterparty_token,
            counterparty_token_amount
        );
        vm.stopPrank();
    }
    
    // Helper function: user x funds a deal

    // Helper function to get deal details for deal y
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

    // Helper function to assert deal created correctly
    function assertDealCreatedCorrectly(
        Verifier.Deal memory deal,
        address party,
        address counterparty,
        address party_token,
        uint256 party_token_amount,
        address counterparty_token,
        uint256 counterparty_token_amount
    ) internal {
        assertEq(deal.party, party, "incorrect party address");
        assertEq(deal.counterparty, counterparty, "incorrect counterparty address");
        assertEq(deal.party_token, party_token, "incorrect party token address");
        assertEq(deal.party_token_amount, party_token_amount, "incorrect party token amount");
        assertEq(deal.counterparty_token, counterparty_token, "incorrect counterparty token address");
        assertEq(deal.counterparty_token_amount, counterparty_token_amount, "incorrect counterparty token amount");
        assertFalse(deal.party_funded, "incorrect party funded status");
        assertFalse(deal.counterparty_funded, "incorrect counterparty funded status");
        assertFalse(deal.deal_canceled, "incorrect deal canceled status");
        assertFalse(deal.deal_executed, "incorrect deal executed status");
    }

    ////////// TEST FUNCTIONS //////////

    // TEST VERIFIER ADDRESS ON ESCROW
    function testVeriferAddressOnEscrow() public {
        assertEq(
            escrow.viewVerifierAddress(),
            address(verifier),
            "Verifer address mismatch"
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
    }

    // TEST USER 0 CREATES A DEAL
    function testDevAccount0CanCreateDeal0() public {
        
        // Arrange - create the deal for the test
        createDealForTest(
            DEV_ACCOUNT_0,
            DEV_ACCOUNT_1,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT
        );
        
        // Get the deal details from the verifier contract
        Verifier.Deal memory deal = getDealDetails(0);

        // Assert that the deal was created correctly
        assertDealCreatedCorrectly(
            deal,
            DEV_ACCOUNT_0,
            DEV_ACCOUNT_1,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT
        );
    }

    // TODO: TEST USER 1 CAN CREATE A DEAL AFTER USER 0 HAS CREATED A DEAL
    function testDevAccount1CanCreateDeal1() public {
        // Arrange

        // User 0 creates deal 0
        createDealForTest(
            DEV_ACCOUNT_0,
            DEV_ACCOUNT_1,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT
        );

        // Act
        // User 1 creates deal 1
        createDealForTest(
            DEV_ACCOUNT_1,
            DEV_ACCOUNT_0,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT
        );
        
        // Get the deal(1) details from the verifier contract
        Verifier.Deal memory deal = getDealDetails(1);

        // Assert that the deal was created correctly
        assertDealCreatedCorrectly(
            deal,
            DEV_ACCOUNT_1,
            DEV_ACCOUNT_0,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT
        );
    }

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
    }

    // TEST USER 1 CAN FUND A DEAL AFTER USER 0 CREATED IT
    function testUser1CanFundDealCreatedByUserO() public {
        // Arrange - set up the deal
        vm.startPrank(DEV_ACCOUNT_0);
        verifier.createDeal(
            DEV_ACCOUNT_1,
            address(mockLink),
            TOKEN_TRANSFER_AMOUNT,
            address(mockUni),
            TOKEN_TRANSFER_AMOUNT
        );
        vm.stopPrank();

        // Act - user 1 approves and funds the deal
        vm.startPrank(DEV_ACCOUNT_1);
        mockUni.approve(address(escrow), TOKEN_TRANSFER_AMOUNT);
        verifier.fundDeal(0);
        vm.stopPrank();

        // Assert - check the deal was funded correctly
        // check balances of escrow and user
        assertEq(
            mockUni.balanceOf(address(escrow)),
            TOKEN_TRANSFER_AMOUNT,
            "incorrect escrow balance"
        );
        assertEq(
            mockUni.balanceOf(DEV_ACCOUNT_1),
            TOKEN_MINT_BALANCE - TOKEN_TRANSFER_AMOUNT,
            "incorrect user balance"
        );
        
        // check status of deal using helper function
        Verifier.Deal memory deal = getDealDetails(0);
      
        assertTrue(deal.counterparty_funded, "Deal not marked as funded by the counterparty");
        assertFalse(deal.party_funded, "Deal incorrectly marked as funded by the party");
        assertFalse(deal.deal_canceled, "Deal incorrectly marked as canceled");
        assertFalse(deal.deal_executed, "Deal incorrectly marked as executed");

        
    }

    // partyVerifiesAndExecutes()

    // TEST USER 0 CAN VERIFY AND EXECUTE A DEAL
    
    // TODO: FUNCTIONS TO TEST
    // counterpartyVerifiesAndExecutes()
    // executeSwap()
    // checkDealStatus()
    // cancelDeal()
    // withdraw()
}
