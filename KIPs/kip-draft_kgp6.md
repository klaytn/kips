---
kip: 103
title: Treasury Fund Rebalancing
author: Aidan<aidan.kwon@klaytn.foundation>, Toniya<toniya.sun@klaytn.foundation>
discussions-to: https://govforum.klaytn.foundation/t/kgp-6-proposal-to-establish-a-sustainable-and-verifiable-klay-token-economy/157
status: Draft
type: Standards Track
category: Core
created: 2023-02-24
---

## Simple Summary

<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->

This proposal suggests the creation of a smart contract that records the rebalance of treasury funds. The main objective is to facilitate the approval and redistribution of treasury funds to new addresses while keeping record of the sender and receiver details.

## Abstract

<!--A short (~200 word) description of the technical issue being addressed.-->

Organizations need to manage treasury funds in a transparent and accountable manner. The proposed standard aims to make the management of treasury funds more transparent by recording the rebalance of treasury funds. The smart contract will keep records of the addresses which hold the treasury funds before and after rebalancing. It also facilates approval before execution.

## Motivation

<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->

Transparency is the one of most important aspect of blockchain. It is important to ensure that treasury funds are allocated and managed in a transparent and verifiable manner. The proposed smart contract aims to disclose the management of treasury funds in a transparent manner through smart contracts reducing the risk of errors and mismanagement. By providing transparency and accountability in the allocation and management of funds, the smart contract can help to build trust and confidence among stakeholders.

## Specification

<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->

The proposed smart contract will be implemented in Solidity and will be compatible with the Ethereum Virtual Machine (EVM). The smart contract will use the `@klaytn/contracts` Ownable contract to restrict access to certain functions to the owner of the contract.

The smart contract will have the following features:

- Add/Remove fund addresses
- Approve fund addresses and fund allocation
- Reset the storage values at any unforeseen circumstances before Finalized
- Finalize the smart contract after execution

### Smart Contracts Overview

#### Enums

The smart contract will have the following enum to track the status of the contract:

- `Initialized`: The initial state of the contract.
- `Registered`: Senders and receivers registered.
- `isApproved`: Senders approved.
- `Finalized`: Rebalance executed and finalized.

#### Life Cycle

The contract status should follow the ENUM order above during status change. The only way to go to previous state is by calling Reset() function.

![](../assets/kip-103/lifecycle.png)

#### Structs

The smart contract will have the following structs :

- `Sender`: to store the details of sender and approver addresses.
- `Receiver`: to store receiver and amount.

#### Storage

The smart contract will have the following storage variables:

- `senders`: array of sender structs.
- `receivers`: array of receiver structs.
- `status`: current status of the contract.
- `rebalanceBlockNumber`: Block number of the execution of rebalancing.
- `memo`: result of the treasury fund rebalance.

#### Modifiers

The smart contract will have the following modifier:

- `atStatus`: to restrict access to certain functions based on the current status of the contract.

#### Constructor

The smart contract will have the following constructor:

- `constructor`: to initialize the contract with the block number of the execution of re balance.

#### State Changing Functions

The smart contract will have the following state changing functions:

- `registerSender`: to register sender details. Senders stores the senders and approvers
- `removeSender`: to remove sender details from the array.
- `registerReceiver`: to register receiver address and its fund distribution.
- `removeReceiver`: to remove receiver details from the array.
- `approve`: app
- `setStatus`: to set the current status of the contract only by owner.
  </br>
  **Conditions**
  - every sender is approved
  - min required admin’s approval is done for sender contract address.
  - sum of sender’s balance is greater than treasury amount
    </br>
    ENUM order should be followed to setStatus
  - Initialized → Registered → Approved → Finalized ✅
  - Initialized → Registered → Finalized ❌
  - Initialized → Approved ❌
  - Initialized → Finalized ❌
- `reset`: resets all storage values to empty objects except rebalanceBlockNumber.
- `finalizeContract`: to record the execution result of the rebalance and finalize the contract. The storage data cannot be modified after this stage.

#### Fallback Function

The smart contract will have a fallback function to revert any payments. Since its a treasury contract it should not accept any payments nor it should allow any withdrawal.

## Rationale

<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->

The smart contract is mainly for recording the details, and the Core will execute the fund re-distributions.

### Design decision

#### KLAY transfer is not allowed via smart contracts

As the balance of treasury funds keeps increasing for every block with the block reward its hard to keep track of the balances and rebalance token allocation. So smart contract will only record the rebalanced allocation and the core will execute the allocation reading from the contract.

#### Approval of senderAddress

To record the addresses in a verifiable manner the addresses are verified in the contract by calling approve method. The senderAddress can be a Contract address or a Externally Owned Account. If the sender address is a

- EOA : EOA address can be verified when the account holder directly calls the approve function. `msg.sender == senderAddress`
- Contract : Contract address can be verified when the admin of the contract calls approve function. The smart contract uses the getState() function implemented in the senderAddress contract to get the admin details. Min required admins should approve the senderAddress contract.
  `msg.sender == admin`

#### No Withdrawal

Smart contract is not allowed to receive KLAY due to security reasons. So any funds send the contract will be reverted and withdraw function is not implemented.

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
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@klaytn/contracts/access/Ownable.sol";
import "hardhat/console.sol";

/**
 * @title Smart contract to record the rebalance of treasury funds.
 * This contract is to mainly record the addresses which holds the treasury funds
 * before and after rebalancing. It facilates approval and redistributing to new addresses.
 */
contract TreasuryRebalance is Ownable {
    /**
     *  Enums to track the status of the contract
     */
    enum Status {
        Initialized,
        Registered,
        Approved,
        Finalized
    }

    /**
     * Sender struct to store the details of sender and approver addresses
     */
    struct Sender {
        address sender;
        address[] approvers;
    }

    /**
     * Receiver struct to store reciever and amount
     */
    struct Receiver {
        address receiver;
        uint256 amount;
    }

    /**
     * Storage
     */
    Sender[] public senders; //array of sender structs
    Receiver[] public receivers; //array of receiver structs
    Status public status; //current status of the contract
    uint256 public rebalanceBlockNumber; //Block number of the execution of rebalancing
    string public memo; //result of the treasury fund rebalnce

    /**
     * Events logs
     */
    event DeployContract(
        Status status,
        uint256 rebalanceBlockNumber,
        uint256 deployedBlockNumber
    );
    event RegisterSender(address sender, address[] approvers);
    event RemoveSender(address sender, uint256 senderCount);
    event RegisterReceiver(address receiver, uint256 fundAllocation);
    event RemoveReceiver(address receiver, uint256 receiverCount);
    event GetState(bool success, bytes result);
    event Approve(address sender, address approver, uint256 approversCount);
    event SetStatus(Status currentStatus, Status upcomingStatus);
    event Finalized(string memo, Status status);

    /**
     * Modifiers
     */
    modifier atStatus(Status _status) {
        require(status == _status, "function not allowed at this stage");
        _;
    }

    /**
     *  Constructor
     * @param _rebalanceBlockNumber is the target block number to execute the redistribution in Core
     */
    constructor(uint256 _rebalanceBlockNumber) {
        rebalanceBlockNumber = _rebalanceBlockNumber;
        status = Status.Initialized;
        emit DeployContract(status, _rebalanceBlockNumber, block.timestamp);
    }

    //State changing Functions
    /**
     * @dev registers sender details
     * @param _senderAddress is the address of the sender
     */
    function registerSender(
        address _senderAddress
    ) public onlyOwner atStatus(Status.Initialized) {
        require(!senderExists(_senderAddress), "Sender is already registered");
        Sender storage sender = senders.push();
        sender.sender = _senderAddress;
        emit RegisterSender(sender.sender, sender.approvers);
    }

    /**
     * @dev remove the sender details from the array
     * @param _senderAddress is the address of the sender
     */
    function removeSender(
        address _senderAddress
    ) public onlyOwner atStatus(Status.Initialized) {
        uint senderIndex = getSenderIndex(_senderAddress);
        senders[senderIndex] = senders[senders.length - 1];
        senders.pop();

        emit RemoveSender(_senderAddress, senders.length);
    }

    /**
     * @dev registers receiver address and its fund distribution
     * @param _receiverAddress is the address of the receiver
     * @param _amount is the fund to be allocated to the receiver
     */
    function registerReceiver(
        address _receiverAddress,
        uint256 _amount
    ) public onlyOwner atStatus(Status.Initialized) {
        require(
            !receiverExists(_receiverAddress),
            "Receiver is already registered"
        );
        require(_amount != 0, "Amount cannot be set to 0");

        Receiver memory receiver = Receiver(_receiverAddress, _amount);
        receivers.push(receiver);

        emit RegisterReceiver(_receiverAddress, _amount);
    }

    /**
     * @dev remove the receiver details from the array
     * @param _receiverAddress is the address of the sender
     */
    function removeReceiver(
        address _receiverAddress
    ) public onlyOwner atStatus(Status.Initialized) {
        uint receiverIndex = getReceiverIndex(_receiverAddress);
        receivers[receiverIndex] = receivers[receivers.length - 1];
        receivers.pop();

        emit RemoveReceiver(_receiverAddress, receivers.length);
    }

    /**
     * @dev senderAddress can be a EOA or a contract address. To approve:
     *      If the senderAddress is a EOA, the msg.sender should be the EOA address
     *      If the senderAddress is a Contract, the msg.sender should be one of the contract `admin`.
     *      It uses the getState() function in the senderAddress contract to get the admin details.
     * @param _senderAddress is the address of the sender
     */
    function approve(
        address _senderAddress
    ) public atStatus(Status.Registered) {
        require(
            senderExists(_senderAddress),
            "sender needs to be registered before approval"
        );

        //Check whether the sender address is EOA or contract address
        bool isContract = isContractAddr(_senderAddress);
        if (!isContract) {
            //check whether the msg.sender is the sender if its a EOA
            require(
                msg.sender == _senderAddress,
                "senderAddress is not the msg.sender"
            );
            _updateApprover(_senderAddress, msg.sender);
        } else {
            //check if the msg.sender is one of the admin of the senderAddress contract
            require(
                _validateAdmin(_senderAddress, msg.sender),
                "msg.sender is not the admin"
            );
            _updateApprover(_senderAddress, msg.sender);
        }
    }

    /**
     * @dev validate if the msg.sender is admin if the senderAddress is a contract
     * @param _senderAddress is the address of the contract
     * @param _approver is the msg.sender
     * @return isAdmin true is the msg.sender is one of the admin
     */
    function _validateAdmin(
        address _senderAddress,
        address _approver
    ) private returns (bool isAdmin) {
        (address[] memory adminList, ) = _getState(_senderAddress);
        require(adminList.length != 0, "admin list cannot be empty");
        for (uint8 i = 0; i < adminList.length; i++) {
            if (_approver == adminList[i]) {
                isAdmin = true;
            }
        }
    }

    /**
     * @dev gets the adminList and quorom by calling `getState()` method in senderAddress contract
     * @param _senderAddress is the address of the contract
     * @return adminList list of the senderAddress contract admins
     * @return req min required number of approvals
     */
    function _getState(
        address _senderAddress
    ) private returns (address[] memory adminList, uint256 req) {
        //call getState() function in senderAddress contract to get the adminList
        bytes memory payload = abi.encodeWithSignature("getState()");
        (bool success, bytes memory result) = _senderAddress.staticcall(
            payload
        );
        emit GetState(success, result);
        require(success, "call failed");

        (adminList, req) = abi.decode(result, (address[], uint256));
    }

    /**
     * @dev Internal function to update the approver details of a sender
     * _senderAddress is the address of the sender
     * _approver is the admin of the senderAddress
     */
    function _updateApprover(
        address _senderAddress,
        address _approver
    ) private {
        uint index = getSenderIndex(_senderAddress);
        address[] memory approvers = senders[index].approvers;
        for (uint i = 0; i < approvers.length; i++) {
            require(
                approvers[i] != _approver,
                "Duplicate approvers cannot be allowed"
            );
        }
        senders[index].approvers.push(_approver);
        emit Approve(
            _senderAddress,
            _approver,
            senders[index].approvers.length
        );
    }

    /**
     * @dev Sets the status of the contract. Functions will be restricted
     * based on the current status
     * @param _status is the status of the contract to be set
     */
    function setStatus(Status _status) public onlyOwner {
        Status currentStatus = status;

        if (
            (currentStatus == Status.Initialized) &&
            (_status == Status.Registered)
        ) {
            status = _status;
        } else if (
            (currentStatus == Status.Registered) && (_status == Status.Approved)
        ) {
            _isSendersApproved();
            uint256 treasuryAmount = getTreasuryAmount();
            require(
                treasuryAmount < sumOfSenderBalance(),
                "treasury amount should be less than the sum of all sender address balances"
            );
            status = _status;
        } else {
            revert("Invalid input status");
        }
        emit SetStatus(currentStatus, _status);
    }

    /**
     * @dev verify if quorom reached for the sender approvals
     */
    function _isSendersApproved() private {
        for (uint i = 0; i < senders.length; i++) {
            Sender memory sender = senders[i];
            (, uint256 req) = _getState(sender.sender);
            if (sender.approvers.length >= req) {
                //if min quorom reached, make sure all approvers are still valid
                address[] memory approvers = sender.approvers;
                uint minApprovals = 0;
                for (uint j = 0; j < approvers.length; j++) {
                    _validateAdmin(senders[i].sender, approvers[j]);
                    minApprovals++;
                }
                require(
                    minApprovals >= req,
                    "min required admins should approve"
                );
            } else {
                revert("min required admins should approve");
            }
        }
    }

    /**
     * @dev sets the status of the contract to Finalize. Once finalized the storage data
     * of the contract cannot be modified
     * @param _memo is the result of the rebalance after executing successfully in the core.
     */
    function finalizeContract(
        string memory _memo
    ) public onlyOwner atStatus(Status.Approved) {
        memo = _memo;
        status = Status.Finalized;
        emit Finalized(memo, status);
    }

    /**
     * @dev resets all storage values to empty objects except targetBlockNumber
     */
    function reset() public onlyOwner {
        //reset cannot be called at Finalized status or after target block.number
        require(
            ((status != Status.Finalized) &&
                (block.number < rebalanceBlockNumber)),
            "Contract is finalized, cannot reset values"
        );

        //`delete` keyword is used to set a storage variable or a dynamic array to its default value.
        delete senders;
        delete receivers;
        delete memo;
        status = Status.Initialized;
    }

    //Getters
    /**
     * @dev to get sender details by senderAddress
     * @param _senderAddress is the address of the sender
     */
    function getSender(
        address _senderAddress
    ) public view returns (address, address[] memory) {
        require(senderExists(_senderAddress), "Sender does not exist");
        uint index = getSenderIndex(_senderAddress);
        Sender memory sender = senders[index];
        return (sender.sender, sender.approvers);
    }

    /**
     * @dev check whether senderAddress is registered
     * @param _senderAddress is the address of the sender
     */
    function senderExists(address _senderAddress) public view returns (bool) {
        require(_senderAddress != address(0), "Invalid address");
        for (uint8 i = 0; i < senders.length; i++) {
            if (senders[i].sender == _senderAddress) {
                return true;
            }
        }
    }

    /**
     * @dev get index of the sender in the senders array
     * @param _senderAddress is the address of the sender
     */
    function getSenderIndex(address _senderAddress) public view returns (uint) {
        for (uint i = 0; i < senders.length; i++) {
            if (senders[i].sender == _senderAddress) {
                return i;
            }
        }
        revert("Sender does not exist");
    }

    /**
     * @dev to calculate the sum of senders balances
     * @return sendersBalance the sum of balances of senders
     */
    function sumOfSenderBalance() public view returns (uint256 sendersBalance) {
        for (uint8 i = 0; i < senders.length; i++) {
            address senderAddress = senders[i].sender;
            sendersBalance += senderAddress.balance;
        }
        return sendersBalance;
    }

    /**
     * @dev to get receiver details by receiverAddress
     * @param _receiverAddress is the address of the receiver
     * @return receiver is the address of the receiver
     * @return amount is the fund allocated to the receiver

     */
    function getReceiver(
        address _receiverAddress
    ) public view returns (address, uint256) {
        require(receiverExists(_receiverAddress), "Receiver does not exist");
        uint index = getReceiverIndex(_receiverAddress);
        Receiver memory receiver = receivers[index];
        return (receiver.receiver, receiver.amount);
    }

    /**
     * @dev check whether _receiverAddress is registered
     * @param _receiverAddress is the address of the receiver
     */
    function receiverExists(
        address _receiverAddress
    ) public view returns (bool) {
        require(_receiverAddress != address(0), "Invalid address");
        for (uint8 i = 0; i < receivers.length; i++) {
            if (receivers[i].receiver == _receiverAddress) {
                return true;
            }
        }
    }

    /**
     * @dev get index of the receiver in the receivers array
     * @param _receiverAddress is the address of the receiver
     */
    function getReceiverIndex(
        address _receiverAddress
    ) public view returns (uint) {
        for (uint i = 0; i < receivers.length; i++) {
            if (receivers[i].receiver == _receiverAddress) {
                return i;
            }
        }
        revert("Receiver does not exist");
    }

    /**
     * @dev to calculate the sum of receiver funds
     * @return treasuryAmount the sum of receiver funds
     */
    function getTreasuryAmount() public view returns (uint256 treasuryAmount) {
        for (uint8 i = 0; i < receivers.length; i++) {
            treasuryAmount += receivers[i].amount;
        }
        return treasuryAmount;
    }

    /**
     * @dev gets the length of senders list
     */
    function getSenderCount() public view returns (uint256) {
        return senders.length;
    }

    /**
     * @dev gets the length of receivers list
     */
    function getReceiverCount() public view returns (uint256) {
        return receivers.length;
    }

    /**
     * @dev allback function to revert any payments
     */
    fallback() external payable {
        revert("This contract does not accept any payments");
    }

    /**
     * @dev Helper function to check the address is contract addr or EOA
     */
    function isContractAddr(address _addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
```

## Test Cases

<!--Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.-->

https://github.com/Krustuniverse-Klaytn-Group/treasury-rebalance/blob/dev/test/TreasuryRebalance.js

## Reference

n/a

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
