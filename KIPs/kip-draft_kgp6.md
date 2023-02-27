---
kip: 103
title: Treasury Fund Rebalancing
author: Aidan<aidan.kwon@krustuniverse.com>,
Toniya<toniya.sun@krustuniverse.com>
discussions-to: https://govforum.klaytn.foundation/t/kgp-6-proposal-to-establish-a-sustainable-and-verifiable-klay-token-economy/157
status: Draft
type: Standards Track
category : Core
created: 2023-02-24
---

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->
This proposal suggests the creation of a smart contract that records the rebalance of treasury funds. The main objective is to facilitate the approval and redistribution of treasury funds to new addresses while keeping record of the sender and receiver details.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
Organizations need to manage treasury funds in a transparent and accountable manner. The proposed standard aims to make the management of treasury funds more transparent by recording the rebalance of treasury funds. The smart contract will keep records of the addresses which hold the treasury funds before and after rebalancing. It also facilates approval and redistributing to new addresses.
 
## Motivation
<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->
Transparency is the one of most important aspect of blockchain. It is important to ensure that treasury funds are allocated and managed in a transparent and verifiable manner. The proposed smart contract aims to disclose the management of treasury funds in a transparent manner through smart contracts reducing the risk of errors and mismanagement.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->
The proposed smart contract will be implemented in Solidity and will be compatible with the Ethereum Virtual Machine (EVM). The smart contract will use the @klaytn/contracts Ownable contract to restrict access to certain functions to the owner of the contract.

The smart contract will have the following features:
- Add/Remove fund addresses
- Approve fund addresses and fund allocation 
- Finalize the smart contract after execution  

### Smart Contracts Overview
#### Enums
The smart contract will have the following enum to track the status of the contract:

- `Initialized`: The initial state of the contract.
- `Registered`: Senders and receivers registered.
- `isApproved`: Senders approved.
- `Finalized`: Rebalance executed and finalized.

#### Structs
The smart contract will have the following structs :

- `Sender`: to store the details of sender and approver addresses.
- `Receiver`: to store receiver and amount.

#### Storage 
The smart contract will have the following storage variables:

- `senders`: array of sender structs.
- `receivers`: array of receiver structs.
- `status`: current status of the contract.
- `treasuryAmount`: target amount of the treasury.
- `totalBalance`: sum of all balances of sender addresses.
- `totalAmount`: sum of all funds allocated to receiver address.
- `memo`: result of the treasury fund rebalance.

#### Event Logs 
The smart contract will emit the following events:

- `DeployContract`: to log the deployment of the contract.
- `RegisterSender`: to log the registration of a sender address.
- `RemoveSender`: to log the removal of a sender address.
- `RegisterReceiver`: to log the registration of a receiver address.
- `RemoveReceiver`: to log the removal of a receiver address.
- `GetState`: to log the result of the `getState()` function in the senderAddress contract.
- `Approve`: to log the approval of a sender address.
- `SetStatus`: to log the change in status of the contract.
- `Finalized`: to log the finalization of the contract.

#### Modifiers
The smart contract will have the following modifier:

- `atStatus`: to restrict access to certain functions based on the current status of the contract.

#### Constructor
The smart contract will have the following constructor:

- `constructor`: to initialize the contract with the target amount of the treasury.

#### State Changing Functions
The smart contract will have the following state changing functions:

- `registerSender`: to register sender details.
- `removeSender`: to remove sender details from the array.
- `registerReceiver`: to register receiver address and its fund distribution.
- `removeReceiver`: to remove receiver details from the array.
- `approve`: to approve if the msg.sender is the admin of senderAddress which is a contract.
- `setStatus`: to set the current status of the contract.
- `finalizeContract`: to record the execution result of the rebalance and finalize the contract. The storage data cannot be modified after this stage.

#### Getters
The smart contract will have the following getter functions:

- `getSender`: to get sender details by senderAddress.
- `getReceiver`: to get receiver details by receiverAddress.
- `getSenderCount`: to get the length of senders list.
- `getReceiverCount`: to get the length of senders list.

#### Fallback Function
The smart contract will have a fallback function to revert any payments. Since its a treasury contract it should not accept any payments nor it should allow any withdrawal. 

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
The smart contract is mainly for recording the details, and the Core will execute the fund re-distributions. 

### Design decision
#### KLAY transfer is not allowed via smart contracts 
As the balance of treasury funds keeps increasing for every block with the block reward its hard to keep track of the balances and rebalance token allocation. So smart contract will record the rebalanced allocation and the core will execute the allocation reading from the contract. 

#### Approval of senderAddress
To record the addresses in a verifiable manner the addresses are verified in the contract by calling approve method. The senderAddress can be a Contract address or a Externally Owned Account. If the sender address is a
- EOA : EOA address can be verified when the account holder directly calls the approve function. `msg.sender == senderAddress`
- Contract : Contract address can be verified when one of the admins of the contract call approve function. The smart contract uses the getState() function implemented in the senderAddress contract to get the admin details.
`msg.sender == admin`

#### No Withdrawal
Smart contract is not allowed to receive KLAY due to securiry reasons. So any funds send the contract will be reverted and withdraw function is not implemented. 

#### Finalize Contract
Once the re-distribution a.k.a rebalance is executed by the Core, the status of the smart contract will be finalized and any modifications to the storage data will be restricted.

## Backwards Compatibility
<!-- All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright. The authors should answer the question: "Does this KIP require a hard fork?" -->
- The foundation should deploy new TreasuryRebalance contract to record the token redistribution. 
- To rebalance the funds and redistribute in a consistent manner the foundation should burn the designated funds before allocation. 
- This does not affect the backward compatibility as this a newly dpeloyed contract

## Test Cases
<!--Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.-->
Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.

## Implementation
<!--The implementations must be completed before any KIP is given status "Final", but it need not be completed before the KIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->
#### Example implementation
```solidity

```

## Reference 
n/a

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
