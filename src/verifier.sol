// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./IEscrow.sol";

// TODO: better error messages
// TODO: refactor fundDeal as its too long
// TODO: check require statements for any redundancies

contract Verifier {
    // interface to escrow contract
    // declares variable of type IEscrow called "escrow"
    // "escrow" is an instance of the IEscrow contract
    IEscrow public escrow;

    // need to set up constructor to take in address of escrow contract
    // do this when deploying the verifier contract
    constructor(address _escrowAddress) {
        escrow = IEscrow(_escrowAddress);
    }

    // modifiers
    modifier onlyParty(uint dealId) {
        require(
            msg.sender == deals[dealId].party,
            "Only the party can perform this action"
        );
        _;
    }

    modifier onlyCounterparty(uint dealId) {
        require(
            msg.sender == deals[dealId].counterparty,
            "Only the counterparty can perform this action"
        );
        _;
    }

    // events
    event DealCreated(
        uint indexed dealId,
        address indexed party,
        address indexed counterparty,
        address party_token,
        uint party_token_amount,
        address counterparty_token,
        uint counterparty_token_amount
    );
    event PartyFunded(uint indexed dealId, address indexed party);
    event CounterPartyFunded(uint indexed dealId, address indexed counterparty);
    event DealCanceled(uint indexed dealId);
    event SwapExecuted(uint indexed dealId, bool indexed deal_verified);

    // a deal defines the terms of a transaction
    // created by owner when they want to make an offer to a counterparty
    struct Deal {
        address party;
        address counterparty;
        address party_token;
        uint party_token_amount;
        address counterparty_token;
        uint counterparty_token_amount;
        bool party_funded;
        bool counterparty_funded;
        bool deal_canceled;
        bool deal_executed;
    }

    // state variables
    // public array of Deal structs called "deals"
    Deal[] public deals;

    mapping(address => uint[]) public partyToDeal; // maps party address to deal ids
    mapping(address => uint[]) public counterpartyToDeal; // maps counterparty address to deal ids

    // functions
    function createDeal(
        address counterparty,
        address party_token,
        uint party_token_amount,
        address counterparty_token,
        uint counterparty_token_amount
    ) public {
        // create dealId and push to deals array
        deals.push(
            Deal(
                msg.sender,
                counterparty,
                party_token,
                party_token_amount,
                counterparty_token,
                counterparty_token_amount,
                false,
                false,
                false,
                false
            )
        );
        uint dealId = deals.length - 1;

        // set Party and Counterparty ownership with mappings and deal id
        partyToDeal[msg.sender].push(dealId);
        counterpartyToDeal[counterparty].push(dealId);

        // emit DealCreated event
        emit DealCreated(
            dealId,
            msg.sender,
            counterparty,
            party_token,
            party_token_amount,
            counterparty_token,
            counterparty_token_amount
        );
    }

    function fundDeal(uint dealId) public {
        // check deal is not verified, completed or canceled already and that msg.sender is party or counterparty
        require(
            checkDealStatus(dealId),
            "Deal cannot be funded in its current state"
        );
        require(
            msg.sender == deals[dealId].party ||
                msg.sender == deals[dealId].counterparty,
            "Only the party or counterparty can fund the deal"
        );

        // state variables
        address funder = msg.sender;
        Deal storage deal = deals[dealId];

        // process funding for Party
        if (funder == deal.party) {
            require(!deal.party_funded, "Party has already funded the deal");

            // call deposit function on escrow.sol contract
            // the escrow object knows the deposit method exists because
            // it is defind in the IEscrow interface
            escrow.deposit(
                dealId,
                funder,
                deal.party_token,
                deal.party_token_amount
            );

            // update deal.party_funded to true
            deal.party_funded = true;

            // checks if the counterparty has already funded the deal
            // if yes - execute swap, if no - emit PartyFunded event
            if (deal.counterparty_funded) {
                partyVerifiesAndExecutes(dealId);
            } else {
                emit PartyFunded(dealId, deal.party);
            }
        }
        // process funding for Counterparty
        else if (funder == deal.counterparty) {
            require(
                !deal.counterparty_funded,
                "Counterparty has already funded the deal"
            );

            // call deposit function on escrow.sol
            escrow.deposit(
                dealId,
                funder,
                deal.counterparty_token,
                deal.counterparty_token_amount
            );

            // update deal.counterparty_funded to true
            deal.counterparty_funded = true;

            // checks if the party has already funded the deal
            // if yes - execute swap, if no - emit CounterpartyFunded event
            if (deal.party_funded) {
                counterpartyVerifiesAndExecutes(dealId);
            } else {
                emit CounterPartyFunded(dealId, deal.counterparty);
            }
        }
    }

    // checks that counterparty has funded the deal and updates the deal_verified state to true
    function partyVerifiesAndExecutes(uint dealId) public onlyParty(dealId) {
        require(deals[dealId].counterparty_funded == true);
        executeSwap(dealId);
    }

    // checks that party has funded the deal and updates the deal_verified state to true
    function counterpartyVerifiesAndExecutes(
        uint dealId
    ) public onlyCounterparty(dealId) {
        require(deals[dealId].party_funded == true);
        executeSwap(dealId);
    }

    // checks that deal is funded, and not completed or canceled
    // keep this private as it is only called by the
    // partyVerifiesAndExecutes and counterpartyVerifiesAndExecutes functions
    function executeSwap(uint dealId) private {
        require(
            deals[dealId].party_funded == true && // could be redundant
                deals[dealId].counterparty_funded == true, // could be redundant
            "Both parties must fund the deal to execute the swap"
        );

        // TODO: swaps ownership of the stakes on escrow.sol
        // I think this is redundant, just need to update deal state

        // set deal_verified to true
        deals[dealId].deal_executed = true;
        emit SwapExecuted(dealId, deals[dealId].deal_executed);
    }

    function checkDealStatus(uint dealId) public view returns (bool) {
        if (
            deals[dealId].deal_executed == true ||
            deals[dealId].deal_canceled == true
        ) {
            return false;
        }
        return true;
    }

    function cancelDeal(uint dealId) public {
        require(
            (msg.sender == deals[dealId].party &&
                deals[dealId].party_funded == true) ||
                (msg.sender == deals[dealId].counterparty &&
                    deals[dealId].counterparty_funded == true),
            "Only a funded party or counterparty can cancel"
        );
        require(
            checkDealStatus(dealId),
            "Deal cannot be canceled in its current state"
        );
        deals[dealId].deal_canceled = true;
        emit DealCanceled(dealId);
    }

    function withdraw(uint dealId) public {
        // checks that the deal is either executed or canceled
        require(checkDealStatus(dealId) == false);

        // check msg sender is party or counterparty
        require(
            (msg.sender == deals[dealId].party) ||
                (msg.sender == deals[dealId].counterparty)
        );

        // set withdrawer and deal variables
        address withdrawer = msg.sender;
        Deal storage deal = deals[dealId];

        // CANCELLED DEAL: both parties can withdraw their original stakes
        if (deal.deal_canceled == true) {
            // if withdrawer is party withdraw party stake and set party_token_amount to zero
            if (withdrawer == deal.party) {
                escrow.withdraw(
                    dealId,
                    withdrawer,
                    deal.party_token,
                    deal.party_token_amount
                );
                deal.party_token_amount = 0;
                // if withdrawer is counterparty withdraw counterparty stake and set counterparty_token_amount to zero
            } else if (withdrawer == deal.counterparty) {
                escrow.withdraw(
                    dealId,
                    withdrawer,
                    deal.counterparty_token,
                    deal.counterparty_token_amount
                );
                deal.counterparty_token_amount = 0;
            }
        }
        // EXECUTED DEAL: both parties can withdraw the swapped stake
        else if (deal.deal_executed == true) {
            // if withdrawer is party withdraw counterparty stake and set counterparty_token_amount to zero
            if (withdrawer == deal.party) {
                escrow.withdraw(
                    dealId,
                    withdrawer,
                    deal.counterparty_token,
                    deal.counterparty_token_amount
                );
                deal.counterparty_token_amount = 0;
                // if withdrawer is counterparty withdraw party stake and set party_token_amount to zero
            } else if (withdrawer == deal.counterparty) {
                escrow.withdraw(
                    dealId,
                    withdrawer,
                    deal.party_token,
                    deal.party_token_amount
                );
                deal.party_token_amount = 0;
            }
        }
    }

    // view Escrow address
    function viewEscrowAddress() public view returns (address) {
        return address(escrow);
    }
}
