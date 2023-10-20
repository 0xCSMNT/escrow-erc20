// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

// Testing changes

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

    event PartyFunded(uint indexed dealId, address indexed party);
    event CounteryPartyFunded(
        uint indexed dealId,
        address indexed counterparty
    );
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
        bool deal_verified; // I think this is redundant
        bool deal_canceled;
        bool deal_completed; // Dont need both deal_verified and deal_completed
    }

    // state variables
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
    require(checkDealStatus(dealId), "Deal cannot be funded in its current state");
    require(msg.sender == deals[dealId].party || msg.sender == deals[dealId].counterparty, 
            "Only the party or counterparty can fund the deal");
    
    // process funding for Party
    if (msg.sender == deals[dealId].party) {
        require(!deals[dealId].party_funded, "Party has already funded the deal");
        
        // TODO: call deposit function on escrow.sol
        
        deals[dealId].party_funded = true;
        
        if (deals[dealId].counterparty_funded) {
            partyVerifiesAndExecutes(dealId);
        } else {
            emit PartyFunded(dealId, deals[dealId].party);
        }
    } 
    // process funding for Counterparty
    else if (msg.sender == deals[dealId].counterparty) {
        require(!deals[dealId].counterparty_funded, "Counterparty has already funded the deal");
        
        // TODO: call deposit function on escrow.sol
        
        deals[dealId].counterparty_funded = true;
        
        if (deals[dealId].party_funded) {
            counterpartyVerifiesAndExecutes(dealId);
        } else {
            emit CounteryPartyFunded(dealId, deals[dealId].counterparty);
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

    // checks that deal is funded, and not verified, completed or canceled
    function executeSwap(uint dealId) internal {
        require(
            deals[dealId].party_funded == true &&
                deals[dealId].counterparty_funded == true,
            "Both parties must fund the deal to execute the swap"
        );

        // TODO: swaps ownership of the stakes on escrow.sol        

        // set deal_verified to true
        deals[dealId].deal_verified = true;
        emit SwapExecuted(dealId, deals[dealId].deal_verified);
    }

    function checkDealStatus(uint dealId) public view returns (bool) {
        if (
            deals[dealId].deal_verified == true ||
            deals[dealId].deal_completed == true ||
            deals[dealId].deal_canceled == true
        ) {
            return false;
        }
        return true;
    }

    function cancelDeal(uint dealId) public {
        require (
                (msg.sender == deals[dealId].party && deals[dealId].party_funded == true) ||
                (msg.sender == deals[dealId].counterparty && deals[dealId].counterparty_funded) == true);
        require(checkDealStatus(dealId), "Deal cannot be canceled in its current state");
        deals[dealId].deal_canceled = true;
        emit DealCanceled(dealId);
    }
}
