---
kip: 103
title: Treasury Fund Rebalancing
author: Aidan (@aidan-kwon), Toniya (@toniya-klaytn)
discussions-to: https://govforum.klaytn.foundation/t/kgp-6-proposal-to-establish-a-sustainable-and-verifiable-klay-token-economy/157
status: Draft
type: Standards Track
category: Core
created: 2023-02-24
---

## Simple Summary

<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->

This proposal suggests a smart contract interface standard that records the rebalance of treasury funds. The main objective is to facilitate the approval and redistribution of treasury funds to new addresses while keeping record of the the previous fund addresses.

## Abstract

<!--A short (~200 word) description of the technical issue being addressed.-->

Organizations need to manage treasury funds in a transparent and accountable manner. The proposed standard aims to make the management of treasury funds more transparent by recording the rebalance of treasury funds. The smart contract will keep records of the addresses which hold the treasury funds before and after rebalancing. It also facilates approval before execution.

## Motivation

<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->

Transparency is the one of most important aspect of blockchain. It is important to ensure that treasury funds are allocated and managed in a transparent and verifiable manner. The proposed smart contract aims to disclose the management of treasury funds in a transparent manner through smart contracts reducing the risk of errors and mismanagement. By providing transparency and accountability in the allocation and management of funds, the smart contract can help to build trust and confidence among stakeholders.

## Specification

<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->

The proposed smart contract will be implemented in Solidity and will be compatible with the Ethereum Virtual Machine (EVM). The smart contract will use Ownable contract to restrict access to certain functions to the owner of the contract.

The smart contract will have the following features:

- Register/Remove fund addresses
  - Previous fund addresses(Retired): Retired fund represents the previous fund addresses such as KGF or KIR
  - New fund addresses(Newbie): Newbie fund represents the 'rebalanced fund' such as KCF or KFF
- Approve fund addresses and fund allocation. Receive approval for asset transfer from the admins/owners of the funds
- Reset the storage values at any unforeseen circumstances before Finalized
- Finalize the smart contract after execution

### Smart Contracts Overview

#### Enums

The smart contract will have the following enum to track the status of the contract:

- `Initialized - 0`: The initial state of the contract.
- `Registered - 1`: Retirees and Newbies are registered.
- `Approved - 2`: All retirees approved by msg.sender
- `Finalized - 3`: Rebalance executed and finalized.

#### Life Cycle

The contract status should follow the ENUM order above during status transition. The only way to go to previous state is by calling Reset() function.

![](../assets/kip-103/lifecycle.png)

Status transition

- Initialized → Registered → Approved → Finalized ✅
- Initialized, Registered, Approved → Initialized, when `reset()` is called.
- Registered, Approved → Initialized, when `reset()` is called.

All other status transitions are not possible.

#### Structs

The smart contract will have the following structs:

- `Retired`: to represent the details of retired and approver addresses.
  - Retired represents the previous fund addresses such as KGF or KIR
  - Approver represents the admin of the retired address. Approver addresses are stored to track the approvals received for asset transfer
- `Newbie`: to represent newbies and their fund allocation.
  - Newbie represents the 'rebalanced fund' such as KCF or KFF

#### Storage

The smart contract will have the following storage variables:

- `retirees`: array of `Retired` struct.
- `newbies`: array of `Newbie` struct.
- `status`: current status of the contract.
- `rebalanceBlockNumber`: the target block number of the execution of rebalancing.
- `memo`: result of the treasury fund rebalance. eg : `Treasury Rebalanced Successfully`

#### Modifiers

The smart contract will have the following modifier:

- `onlyAtStatus`: to restrict access to certain functions based on the current status of the contract. If the status is not the same with the given status, it reverts.

#### Constructor

The smart contract will have the following constructor:

- `constructor`: to initialize the contract with the target block number of the execution of rebalance.

#### State Changing Functions

The smart contract will have the following state changing functions:

- `registerRetired`: to register retired details. Retired stores the retired address and approvers
- `removeRetired`: to remove retired details from the array.
- `registerNewbie`: to register newbie address and its fund distribution.
- `removeNewbie`: to remove newbie details from the array.
- `finalizeRegistration`: sets the status to Registered only executed by owner. After this stage, registrations will be restricted.
- `approve`: to approve a retiredAddress by the admin.
- `finalizeApproval`: sets the status to Approved. After this stage, approvals will be restricted.
  </br>
  **Conditions**
  - every retiredAddress must be approved
  - min required admin’s approval is done for retired contract address.
  - sum of retired’s balance is greater than sum of the newbies' amount
    </br>
- `reset`: resets all storage values to empty objects except rebalanceBlockNumber. It can only be called during Initialization, Registration and Approved status.
- `finalizeContract`: to record the execution result of the rebalance and finalize the contract. The storage data cannot be modified after this stage.

#### Fallback Function

The smart contract will have a fallback function to revert any payments. Since its a treasury contract, it should not accept any payments nor it should allow any withdrawal.

### Core Logic Overview

TBU - describe how to read contract data and execute rebalancing in Klaytn node

## Rationale

<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->

The smart contract is mainly for recording the details, and the Core will execute the fund re-distributions.

### Design decision

#### KLAY transfer is not allowed via smart contracts

As the balance of treasury funds keeps increasing for every block with the block reward its hard to keep track of the balances and rebalance token allocation. So smart contract will only record the rebalanced allocation and the core will execute the allocation by reading from the contract.

#### Approval of retiredAddress

To record the addresses in a verifiable manner, the addresses are verified in the contract by calling approve method. The retiredAddress can either be a Contract Account (CA) or an Externally Owned Account(EOA).

- In case of an EOA, verification occurs when the account holder directly calls the approve function. `msg.sender == retiredAddress`
- In case of a Contract, verification occurs when the admin of the contract calls approve function. The smart contract calls the `getState()` function implemented in the retiredAddress contract to get the admin details. `msg.sender == admin`
  - `getState()` funtion is implemented in Klaytn treasury contracts. It returns the adminList and quorom (min required admins to approve).
  - Condition: Min required admins should approve the retiredAddress contract.

#### No Withdrawal

Smart contract is not allowed to receive KLAY due to security reasons. So any transaction sending KLAY to the contract will be reverted and withdraw function is not implemented.

#### Finalize Contract

Once the re-distribution a.k.a rebalance is executed by the Core, the status of the smart contract will be finalized and any modifications to the storage data will be restricted.

## Backwards Compatibility

<!-- All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright. The authors should answer the question: "Does this KIP require a hard fork?" -->

- The foundation should deploy new TreasuryRebalance contract to record the token redistribution.
- To rebalance the funds and redistribute in a consistent manner the foundation should burn the designated funds before re-distribution.
- This does not affect the backward compatibility as this a newly dpeloyed contract

## Implementation

<!--The implementations must be completed before any KIP is given status "Final", but it need not be completed before the KIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

#### Example implementation

```solidity
interface ITreasuryRebalance {
    // Events
    event ContractDeployed(
        uint256 rebalanceBlockNumber,
        uint256 deployedBlockNumber
    );
    event RetiredRegistered(address retired);
    event RetiredRemoved(address retired, uint256 retiredCount);
    event NewbieRegistered(address newbie, uint256 fundAllocation);
    event NewbieRemoved(address newbie, uint256 newbieCount);
    event Approved(address retired, address approver, uint256 approversCount);
    event StatusChanged(Status status);
    event Finalized(string memo);

    // Enums
    enum Status {
        Initialized,
        Registered,
        Approved,
        Finalized
    }

    struct Retired {
        address retired;
        address[] approvers;
    }

    struct Newbie {
        address newbie;
        uint256 amount;
    }

    // State variables
    function status() external view returns (Status);
    function rebalanceBlockNumber() external view returns (uint256);
    function memo() external view returns (string memory);

    // State changing functions
    function registerRetired(address retiredAddress) external;
    function removeRetired(address retiredAddress) external;
    function registerNewbie(address newbieAddress, uint256 _amount) external;
    function removeNewbie(address newbieAddress) external;
    function approve(address retiredAddress) external;
    function finalizeRegistration() external;
    function finalizeApproval() external;
    function finalizeContract(string memory memo) external view returns(address[] memory retirees, uint256 totalRetireesBalance, address[] memory newbies, uint256 totalNewbiesFund);
    function reset() external;
}
```

Implementation : https://github.com/klaytn/treasury-rebalance/tree/main/contracts

## Test Cases

<!--Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.-->

https://github.com/klaytn/treasury-rebalance/blob/main/test/TreasuryRebalance.js

## Reference

n/a

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
