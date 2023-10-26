# ESCROW ERC20
This dApp is a trustless escrow service for swapping ERC20 tokens between two parties. 

It comprises two smart contracts:
- escrow.sol: Acts as a secure holding area for tokens deposited by both participants in a deal.
- verifier.sol: Manages the state and rules for each deal.

Users can initiate a "deal," where one party ("Party") sets the terms, including the type and amount of tokens they wish to swap. The other participant ("Counterparty") can then agree to these terms and deposit their tokens into escrow. Before finalization, either party can opt to cancel the deal, which allows both to withdraw their initial deposits. Once both parties are satisfied, the deal can be verified, enabling each party to withdraw the tokens deposited by the other. The system is designed for reusability, allowing for multiple concurrent deals.


# Smart Contracts

## escrow.sol
- **Holds the tokens (stakes) deposited by both the Party and the Counterparty.**

### Functions
- `deposit()`: Allows the Party and Counterparty to deposit their respective tokens.
- `withdraw()`: Allows withdrawal based on permissions set in `verifier.sol`.

## verifier.sol
- **Manages the state and logic of each deal.**

### Structs

- `Deal`: Keeps track of all the variables related to a single deal.

  struct Deal {
    address party;
    address counterparty;
    address partyToken;
    address counterpartyToken;
    uint256 partyAmount;
    uint256 counterpartyAmount;
    bool verifiedDeal;
    bool dealCanceled;
}

#### State Variables

- `mapping(uint256 => Deal) public deals;`  
  - Mapping from deal IDs to Deal structs.
  
- `mapping(uint256 => mapping(address => mapping(address => uint256))) public allowedWithdrawals;`  
  - Tracks who is allowed to withdraw what amount of which token for each deal.


### Functions
- `createDeal()`: Initializes a new deal.
- `fundDeal()`: Used by Party and Counterparty to indicate they've funded the escrow.
- `verify_deal(uint256 dealId)`: Verifies a deal, updating `verifiedDeal` to true.
- `cancel_deal(uint256 dealId)`: Allows either participant to cancel the deal before verification.

### Events
- `DealCreated`: Emitted when a new deal is created.
- `DealFunded`: Emitted when Party or Counterparty funds the escrow.
- `DealVerified`: Emitted when a deal is verified.
- `DealCanceled`: Emitted when a deal is canceled.

# Front-End
- **Using Web3.js to interact with the smart contracts.**
- **Will display events and allow users to call functions like `fundDeal`, `verify_deal`, and `cancel_deal`.**

## Transaction Flow (Happy Path)
1. Party creates a new deal via `createDeal()`.
2. Party funds the escrow by calling `deposit()` on `escrow.sol`.
3. Party calls `fundDeal()` on `verifier.sol` to indicate the deal has been funded.
4. Counterparty sees the deal and funds their part via `deposit()` on `escrow.sol`.
5. Counterparty calls `fundDeal()` on `verifier.sol`.
6. Either Party or Counterparty calls `verify_deal()` to finalize the deal.
7. Party and Counterparty can now call `withdraw()` to get each other's stake.

# Development Plan

## Phase 1: Smart Contracts
- [ ] Write `escrow.sol`
  - [x] Implement `deposit()` function for both Party and Counterparty.
  - [ ] Implement `withdraw()` function.
- [x] Write `verifier.sol`
  - [x] Define `Deal` struct.
  - [x] Implement `createDeal()` function.
  - [x] Implement `fundDeal()` function for Party and Counterparty.
  - [x] Implement `verify_deal()` function.
  - [x] Implement `cancel_deal()` function.
- [x] Add events for important state changes.
- [ ] Add inline comments for complex operations within functions

## Phase 2: Front-End
- [ ] Set up a basic front-end using Web3.js.
  - [ ] Implement UI for creating a deal.
  - [ ] Implement UI for funding a deal.
  - [ ] Implement UI for verifying and canceling a deal.
- [ ] Display relevant events.

## Phase 3: Testing and Debugging
- [ ] Write tests for better debugging and improvements.
- [ ] Optimize the code 
  - [ ] Assess gas efficiency
  - [ ] Access Control: Consider Admin Role for upgrades and emergency stops
  - [ ] State Change Order - Checks-Effects-Interactions
  - [ ] Event Handling - Check if more events will help offchain interactions
  - [ ] rework `checkDealStatus()` to be more descriptive
- [ ] Conduct thorough tests on both smart contracts.
- [ ] Test the front-end.
- [ ] Debug and resolve any issues.

## Phase 4: Deployment
- [ ] Deploy smart contracts to a testnet.
- [ ] Test the entire workflow.
- [ ] Deploy to mainnet when ready.
