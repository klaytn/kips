---
kip: 103
title: Treasury Fund Rebalancing
author: Aidan<aidan.kwon@krustuniverse.com>, Toniya<toniya.sun@krustuniverse.com>
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
As the balance of treasury funds keeps increasing for every block with the block reward its hard to keep track of the balances and rebalance token allocation. So smart contract will only record the rebalanced allocation and the core will execute the allocation reading from the contract.

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
        address approver;
        bool isApproved;
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
    uint256 public treasuryAmount; //target amount of the treasury
    uint256 public totalBalance; //sum of all balances of sender addresses
    uint256 public totalAmount; //sum of all funds allocated to receiver address.
    string public memo; //result of the treasury fund rebalnce

    /**
     * Events logs
     */
    event DeployContract(Status status, uint256 treasuryAmount, uint256 deployedBlockNumber);
    event RegisterSender(address sender, address approver, bool isApproved);
    event RemoveSender(address sender, uint256 senderCount);
    event RegisterReceiver(address receiver, uint256 fundAllocation);
    event RemoveReceiver(address receiver, uint256 receiverCount);
    event GetState(bool success, bytes result);
    event Approve(address sender, address approver,bool isApproved, uint256 senderBalance, uint256 totalBalance);
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
     */
    constructor(uint256 _treasuryAmount) {
        status = Status.Initialized;
        require(_treasuryAmount != 0, "Treasury Amount cannot be set to 0");
        treasuryAmount = _treasuryAmount;
        emit DeployContract(status, treasuryAmount, block.timestamp);
    }

    //State changing Functions
    /**
     * @dev registers sender details
     * @param _senderAddress is the address of the sender
     */
    function registerSender(address _senderAddress)
        public
        onlyOwner
        atStatus(Status.Initialized)
    {
        (address senderAddr, , , ) = getSender(_senderAddress);
        require(senderAddr == address(0), "Sender is already registered");
        Sender memory sender = Sender(_senderAddress, address(0), false);
        senders.push(sender);
        emit RegisterSender(_senderAddress, address(0), false);
    }

    /**
     * @dev remove the sender details from the array
     * @param _senderAddress is the address of the sender
     */
    function removeSender(address _senderAddress)
        public
        onlyOwner
        atStatus(Status.Initialized)
    {
        (address senderAddr, , , ) = getSender(_senderAddress);
        require(senderAddr != address(0), "Sender is not registered");
        for (uint256 i = 0; i < senders.length; i++) {
            if (senders[i].sender == _senderAddress) {
                delete senders[i];
                // Move the last element to the position of the deleted element
                senders[i] = senders[senders.length - 1];
                // Remove the last element
                senders.pop();
                break;
            }
        }
        emit RemoveSender(_senderAddress, senders.length);
    }

    /**
     * @dev registers receiver address and its fund distribution
     * @param _receiverAddress is the address of the receiver
     * @param _amount is the fund to be allocated to the receiver
     */
    function registerReceiver(address _receiverAddress, uint256 _amount)
        public
        onlyOwner
        atStatus(Status.Initialized)
    {
        (address receiverAddress, ) = getReceiver(_receiverAddress);
        require(receiverAddress == address(0), "Receiver is already registered");
        Receiver memory receiver = Receiver(_receiverAddress, _amount);
        receivers.push(receiver);
        totalAmount += _amount;
        require(totalAmount <= treasuryAmount,"Receiver funds cannot exceed treasury fund");
        emit RegisterReceiver(_receiverAddress, _amount);
    }

    /**
     * @dev remove the receiver details from the array
     * @param _receiverAddress is the address of the sender
     */
    function removeReceiver(address _receiverAddress)
        public
        onlyOwner
        atStatus(Status.Initialized)
    {
        (address receiverAddr, uint256 amount) = getReceiver(_receiverAddress);
        require(receiverAddr != address(0), "Receiver is not registered");

        for (uint256 i = 0; i < receivers.length; i++) {
            if (receivers[i].receiver == _receiverAddress) {
                delete receivers[i];
                // Move the last element to the position of the deleted element
                receivers[i] = receivers[receivers.length - 1];
                // Remove the last element
                receivers.pop();
                totalAmount -= amount;
                break;
            }
        }
        emit RemoveReceiver(_receiverAddress, receivers.length);
    }

    /**
     * @dev senderAddress can be a EOA or a contract address. To approve:
     *      If the senderAddress is a EOA, the msg.sender should be the EOA address
     *      If the senderAddress is a Contract, the msg.sender should be one of the contract `admin`.
     *      It uses the getState() function in the senderAddress contract to get the admin details.
     * @param _senderAddress is the address of the sender
     */
    function approve(address _senderAddress)
        public
        atStatus(Status.Registered)
    {
        bool approved = false;
        (address sender, , bool isApproved, uint256 index) = getSender(_senderAddress);

        require(isApproved != true, "sender is already approved");
        require(sender != address(0),"sender needs to be registered before approval");
        //Check whether the sender address is EOA or contract address
        bool isContract = isContractAddr(_senderAddress);

        if (!isContract) {
            //check whether the msg.sender is the sender if its a EOA
            require(msg.sender == _senderAddress,"senderAddress is not the msg.sender");
            _updateApprover(_senderAddress, msg.sender, index);
            approved = true;
        } else {
            //call getState() function in sender contract to validate the msg.sender
            bytes memory payload = abi.encodeWithSignature("getState()");
            (bool success, bytes memory result) = _senderAddress.staticcall(payload);
            emit GetState(success, result);
            require(success, "call failed");

            (address[] memory adminList, ) = abi.decode(result,(address[], uint256));
            require(adminList.length != 0, "admin list cannot be empty");
            for (uint256 i = 0; i < adminList.length; i++) {
                if (msg.sender == adminList[i]) {
                    _updateApprover(_senderAddress, msg.sender, index);
                    approved = true;
                }
            }
            require(approved, "msg.sender is not the admin");
        }
    }

    /**
     * @dev Internal function to update the approver details of a sender
     */
    function _updateApprover(
        address _senderAddress,
        address _approver,
        uint256 _index
    ) private {
        senders[_index].approver = _approver;
        senders[_index].isApproved = true;
        totalBalance += _senderAddress.balance;
        emit Approve(
            _senderAddress,
            _approver,
            senders[_index].isApproved,
            _senderAddress.balance,
            totalBalance
        );
    }

    /**
     * @dev Sets the status of the contract. Functions will be restricted
     * based on the current status
     * @param _status is the status of the contract to be set
     */
    function setStatus(Status _status) public onlyOwner {
        Status currentStatus = status;

        if((currentStatus == Status.Initialized) && (_status == Status.Registered)) {
            status = _status;
        }else if((currentStatus == Status.Registered) && (_status == Status.Approved)) {
            require(
                treasuryAmount < totalBalance,
                "treasury amount should be less than the sum of all sender address balances"
            );
            status = _status;
        }else {
            revert("Invalid input status");
        }
        emit SetStatus(currentStatus, _status);
    }

    /**
     * @dev sets the status of the contract to Finalize. Once finalized the storage data
     * of the contract cannot be modifed
     * @param _memo is the result of the rebalance after executing successfully in the core.
     */
    function finalizeContract(string memory _memo)
        public
        onlyOwner
        atStatus(Status.Approved)
    {
        memo = _memo;
        status = Status.Finalized;
        emit Finalized(memo, status);
    }

    //Getters
    /**
     * to get sender details by senderAddress
     * @param _senderAddress is the address of the sender
     * @return sender is the address of the sender
     * @return approver is the address of the approver
     * @return isApproved returns true if its approved
     * @return index returns index of the Sender in the sender list
     */
    function getSender(address _senderAddress)
        public
        view
        returns (
            address sender,
            address approver,
            bool isApproved,
            uint256 index
        )
    {
        for (uint256 i = 0; i < senders.length; i++) {
            if (_senderAddress == senders[i].sender) {
                return (
                    senders[i].sender,
                    senders[i].approver,
                    senders[i].isApproved,
                    i
                );
            }
        }
    }

    /**
     * to get receiver details by receiverAddress
     * @param _receiverAddress is the address of the receiver
     * @return receiver is the address of the receiver
     * @return amount is the fund allocated to the receiver

     */
    function getReceiver(address _receiverAddress)
        public
        view
        returns (address receiver, uint256 amount)
    {
        for (uint256 i = 0; i < receivers.length; i++) {
            if (_receiverAddress == receivers[i].receiver) {
                return (receivers[i].receiver, receivers[i].amount);
            }
        }
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

//Link will be included

## Reference
n/a

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
