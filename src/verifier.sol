// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Verifier {
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

    event DealFunded();
    event DealVerified();
    event DealCanceled();
    event DealCompleted();

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
        bool deal_verified;
        bool deal_canceled;
        bool deal_completed;
    }

    // state variables
    Deal[] public deals;

    mapping(address => uint[]) public partyToDeal; // maps party address to deal ids
    mapping(address => uint[]) public counterpartyToDeal; // maps counterparty address to deal ids

    function createDeal(
        address counterparty,
        address party_token,
        uint party_token_amount,
        address counterparty_token,
        uint counterparty_token_amount
    ) public {
        // create deal id and push to deals array
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
}
