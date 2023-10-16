# ESCROW ERC20
This dApp is a trustless escrow service for swapping ERC20 tokens between two parties. It comprises two smart contracts:

escrow.sol: Acts as a secure holding area for tokens deposited by both participants in a deal.

verifier.sol: Manages the state and rules for each deal.

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
\`\`\`solidity
mapping(uint256 => Deal) public deals; // Mapping from deal IDs to Deal structs.
mapping(uint256 => mapping(address => mapping(address => uint256))) public allowedWithdrawals; // Tracks who is allowed to withdraw what amount of which token for each deal.
\`\`\`

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
  - [ ] Implement `deposit()` function for both Party and Counterparty.
  - [ ] Implement `withdraw()` function.
- [ ] Write `verifier.sol`
  - [ ] Define `Deal` struct.
  - [ ] Implement `createDeal()` function.
  - [ ] Implement `fundDeal()` function for Party and Counterparty.
  - [ ] Implement `verify_deal()` function.
  - [ ] Implement `cancel_deal()` function.
- [ ] Add events for important state changes.
- [ ] Implement reusability features.
- [ ] Write initial tests for smart contracts.

## Phase 2: Front-End
- [ ] Set up a basic front-end using Web3.js.
  - [ ] Implement UI for creating a deal.
  - [ ] Implement UI for funding a deal.
  - [ ] Implement UI for verifying and canceling a deal.
- [ ] Display relevant events.

## Phase 3: Testing and Debugging
- [ ] Conduct thorough tests on both smart contracts.
- [ ] Test the front-end.
- [ ] Debug and resolve any issues.

## Phase 4: Deployment
- [ ] Deploy smart contracts to a testnet.
- [ ] Test the entire workflow.
- [ ] Deploy to mainnet when ready.



## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
