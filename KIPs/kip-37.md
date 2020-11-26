---
kip: 37
title: Token Standard
author: Kyungkoo Kai Kim <kai.kim@groundx.xyz>
discussions-to: https://github.com/klaytn/kips/issues/37
status: Draft
type: Standards Track
category: KCT
created: 2020-08-19
requires: 13
---

## Simple Summary

A standard interface for contracts that manage multiple token types. A single deployed contract may include any combination of fungible tokens, non-fungible tokens or other configurations (e.g. semi-fungible tokens).

## Abstract

This standard outlines a smart contract interface that can represent any number of fungible and non-fungible token types. Existing standards such as KIP-7 require deployment of separate contracts per token type. The KIP-17 standard’s token ID is a single non-fungible index and the group of these non-fungibles is deployed as a single contract with settings for the entire collection. In contrast, the KIP-37 Multi Token Standard allows for each token ID to represent a new configurable token type, which may have its own metadata, supply and other attributes.

The `_id` argument contained in each function’s argument set indicates a specific token or token type in a transaction.

## Motivation

Tokens standards like KIP-7 and KIP-17 require a separate contract to be deployed for each token type or collection. This places a lot of redundant bytecode on the Klaytn blockchain and limits certain functionality by the nature of separating each token contract into its own permissioned address. With the rise of blockchain games and platforms like Enjin Coin, game developers may be creating thousands of token types, and a new type of token standard is needed to support them. However, KIP-37 is not specific to games and many other applications can benefit from this flexibility.

New functionality is possible with this design such as transferring multiple token types at once, saving on transaction costs. Trading (escrow / atomic swaps) of multiple tokens can be built on top of this standard and it removes the need to “approve” individual token contracts separately. It is also easy to describe and mix multiple fungible or non-fungible token types in a single contract.

## Specification

This document is heavily derived from [ERC-1155](https://eips.ethereum.org/EIPS/eip-1155) written by Witek Radomski, Andrew Cooke, Philippe Castonguay, James Therien, Eric Binet, and Ronan Sandford.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

### KIP37 Interface

Smart contracts implementing the KIP-37 standard MUST implement all of the functions in the KIP37 interface.

Smart contracts implementing the KIP-37 standard MUST implement the KIP-13 supportsInterface function and MUST return the constant value true if 0x6433ca1f is passed through the interfaceID argument.

```solidity
pragma solidity 0.5.6;

/**
    @title KIP-37 Multi Token Standard
    @dev See https://kips.klaytn.com/KIPs/kip-37
    Note: The KIP-13 identifier for this interface is 0x6433ca1f.
 */
interface KIP37 /* is KIP13 */ {
    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_id` argument MUST be the token type being transferred.
        The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    */
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_ids` argument MUST be the list of tokens being transferred.
        The `_values` argument MUST be the list of the number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    */
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    /**
        @dev MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absence of an event assumes disabled).
    */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /**
        @dev MUST emit when the URI is updated for a token ID.
        URIs are defined in RFC 3986.
        The URI MUST point to a JSON file that conforms to the "KIP-37 Metadata URI JSON Schema".
    */
    event URI(string _value, uint256 indexed _id);

    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if the balance of the holder `_from` for the token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onKIP37Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onKIP37Received` on `_to`
    */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    /**
        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if the length of `_ids` is not the same as the length of `_values`.
        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
        MUST revert on any other error.
        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `KIP37TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _ids     IDs of each token type (order and length must match _values array)
        @param _values  Transfer amounts per token type (order and length must match _ids array)
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to the `KIP37TokenReceiver` hook(s) on `_to`
    */
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;

    /**
        @notice Get the balance of an account's tokens.
        @param _owner  The address of the token holder
        @param _id     ID of the token
        @return        The _owner's balance of the token type requested
     */
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    /**
        @notice Get the balance of multiple account/token pairs
        @param _owners The addresses of the token holders
        @param _ids    ID of the tokens
        @return        The _owner's balance of the token types requested (i.e. balance for each (owner, id) pair)
     */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param _operator  Address to add to the set of authorized operators
        @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param _owner     The owner of the tokens
        @param _operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    /**
        @notice Get the total supply of the token type requested.
        @param _id      ID of the token
        @return         The supply of the token type requested
    */
    function totalSupply(uint256 _id) external view returns (uint256);
}
```

### Differences from ERC-1155

This section describes the differences between KIP-37 and ERC-1155.

- KIP-37 also supports the wallet interface of ERC-1155 (`IERC1155TokenReceiver`) to be compliant with ERC-1155.
- More optional extensions are defined (minting extension, burning extension, and pausing extension).
- `totalSupply` is added to obtain the amount of tokens in existence for each token id.

### KIP-13 Identifiers

The below table shows KIP-13 identifiers for interfaces defined in this proposal.

| Interface                                       | KIP-13 Identifier |
| ----------------------------------------------- | ----------------- |
| [IKIP37](#kip37-interface)                      | 0x6433ca1f        |
| [IKIP37TokenReceiver](#kip-37-token-receiver)   | 0x7cc2d017        |
| [IERC1155TokenReceiver](#kip-37-token-receiver) | 0x4e2312e0        |
| [IKIP37Metadata](#metadata-extension)           | 0x0e89341c        |
| [IKIP37Mintable](#minting-extension)            | 0x84aec3b9        |
| [IKIP37Burnable](#burning-extension)            | 0x9e094e9e        |
| [IKIP37Pausable](#pausing-extension)            | 0x0e8ffdb7        |

### KIP-37 Token Receiver

Smart contracts MUST implement all of the functions in the KIP37TokenReceiver interface to accept transfers. See [Safe Transfer Rules](#safe-transfer-rules) for further detail.

Smart contracts MUST implement the KIP-13 supportsInterface function and signify support for the KIP37TokenReceiver interface to accept transfers. See [KIP37TokenReceiver KIP-13 rules](#kip37tokenreceiver-kip-13-rules) for further detail.

```solidity
pragma solidity 0.5.6;

/**
    Note: The KIP-13 identifier for this interface is 0x7cc2d017.
*/
interface KIP37TokenReceiver {
    /**
        @notice Handle the receipt of a single KIP37 token type.
        @dev A KIP37-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
        This function MUST return `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)"))` (i.e. 0xe78b3325) if it accepts the transfer.
        This function MUST revert if it rejects the transfer.
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _id        The ID of the token being transferred
        @param _value     The amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)"))`
    */
    function onKIP37Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    /**
        @notice Handle the receipt of multiple KIP37 token types.
        @dev A KIP37-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
        This function MUST return `bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))` (i.e. 0x9b49e332) if it accepts the transfer(s).
        This function MUST revert if it rejects the transfer(s).
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the batch transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _ids       An array containing ids of each token being transferred (order and length must match _values array)
        @param _values    An array containing amounts of each token being transferred (order and length must match _ids array)
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    */
    function onKIP37BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}
```

To be compliant with ERC-1155, KIP-37 also supports ERC1155TokenReceiver. This makes the current ERC-1155 implementation on Ethereum can be easily migrated on to Klaytn without any modification.

```solidity
pragma solidity 0.5.6;

/**
    Note: The KIP-13 identifier for this interface is 0x4e2312e0.
*/
interface ERC1155TokenReceiver {
    /**
        @notice Handle the receipt of a single ERC1155 token type.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
        This function MUST return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` (i.e. 0xf23a6e61) if it accepts the transfer.
        This function MUST revert if it rejects the transfer.
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _id        The ID of the token being transferred
        @param _value     The amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    */
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    /**
        @notice Handle the receipt of multiple ERC1155 token types.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
        This function MUST return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` (i.e. 0xbc197c81) if it accepts the transfer(s).
        This function MUST revert if it rejects the transfer(s).
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the batch transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _ids       An array containing ids of each token being transferred (order and length must match _values array)
        @param _values    An array containing amounts of each token being transferred (order and length must match _ids array)
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    */
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}
```

### Safe Transfer Rules

To be more explicit about how the standard `safeTransferFrom` and `safeBatchTransferFrom` functions MUST operate with respect to the `KIP37TokenReceiver` or `ERC1155TokenReceiver` hook functions, a list of scenarios and rules follows.

#### Scenarios

**_Scenario#1 :_** The recipient is not a contract.

- `onKIP37Received` and `onKIP37BatchReceived` MUST NOT be called on an EOA (Externally Owned Account).

**_Scenario#2 :_** The transaction is not a mint/transfer of a token.

- `onKIP37Received` and `onKIP37BatchReceived` MUST NOT be called outside of a mint or transfer process.

**_Scenario#3 :_** The receiver does not implement the necessary `KIP37TokenReceiver` or `ERC1155TokenReceiver` interface function(s).

- The transfer MUST be reverted with the one caveat below. - If the token(s) being sent are part of a hybrid implementation of another standard, that particular standard’s rules on sending to a contract MAY now be followed instead. See [Backwards Compatibility](#backwards-compatibility) section.

**_Scenario#4 :_** The receiver implements the necessary `KIP37TokenReceiver` or `ERC1155TokenReceiver` interface function(s) but returns an unknown value.

- The transfer MUST be reverted.

**_Scenario#5 :_** The receiver implements the necessary `KIP37TokenReceiver` or `ERC1155TokenReceiver` interface function(s) but throws an error.

- The transfer MUST be reverted.

**_Scenario#6 :_** The receiver implements the `KIP37TokenReceiver` or `ERC1155TokenReceiver` interface and is the recipient of one and only one balance change (e.g. `safeTransferFrom` called).

- The balances for the transfer MUST have been updated before the `KIP37TokenReceiver` or `ERC1155TokenReceiver` hook is called on a recipient contract.
- The transfer event MUST have been emitted to reflect the balance changes before the `KIP37TokenReceiver` or `ERC1155TokenReceiver` hook is called on the recipient contract.
- One of `onKIP37Received`, `onKIP37BatchReceived`, `onERC1155Received` or `onERC1155BatchReceived` MUST be called on the recipient contract.
- The `onKIP37Received` or `onERC1155Received` hook SHOULD be called on the recipient contract and its rules followed.
  - See [onKIP37Received rules](#onkip37received-rules) for further rules that MUST be followed.
- The `onKIP37BatchReceived` or `onERC1155BatchReceived` hook MAY be called on the recipient contract and its rules followed.
  - See [onKIP37BatchReceived rules](#onkip37batchreceived-rules) for further rules that MUST be followed.

**_Scenario#7 :_** The receiver implements the `KIP37TokenReceiver` or `ERC1155TokenReceiver` interface and is the recipient of more than one balance change (e.g. `safeBatchTransferFrom` called).

- All balance transfers that are referenced in a call to a `KIP37TokenReceiver` or `ERC1155TokenReceiver` hook MUST be updated before the `KIP37TokenReceiver` or `ERC1155TokenReceiver` hook is called on the recipient contract.
- All transfer events MUST have been emitted to reflect current balance changes before a `KIP37TokenReceiver` or `ERC1155TokenReceiver` hook is called on the recipient contract.
- `onKIP37Received`, `onKIP37BatchReceived`, `onERC1155Received` or `onERC1155BatchReceived` MUST be called on the recipient as many times as necessary such that every balance change for the recipient in the scenario is accounted for.
  - The return magic value for every hook call MUST be checked and acted upon as per [onKIP37Received rules](#onkip37received-rules) and [onKIP37BatchReceived rules](#onkip37batchreceived-rules).
- The `onKIP37BatchReceived` or `onERC1155BatchReceived` hook SHOULD be called on the recipient contract and its rules followed.
  - See [onKIP37BatchReceived rules](#onkip37batchreceived-rules) for further rules that MUST be followed.
- The `onKIP37Received` or `onERC1155Received` hook MAY be called on the recipient contract and its rules followed.
  - See [onKIP37Received rules](#onkip37received-rules) for further rules that MUST be followed.

**_Scenario#8 :_** You are the creator of a contract that implements the `KIP37TokenReceiver` interface and you forward the token(s) onto another address in one or both of `onKIP37Received` and `onKIP37BatchReceived`.

- Forwarding should be considered acceptance and then initiating a new `safeTransferFrom` or `safeBatchTransferFrom` in a new context.
  - The prescribed keccak256 acceptance value magic for the receiver hook being called MUST be returned after forwarding is successful.
- The `_data` argument MAY be re-purposed for the new context.
- If forwarding fails the transaction MAY be reverted.
  - If the contract logic wishes to keep the ownership of the token(s) itself in this case it MAY do so.

**_Scenario#9 :_** You are transferring tokens via a non-standard API call i.e. an implementation specific API and NOT `safeTransferFrom` or `safeBatchTransferFrom`.

- In this scenario, all balance updates and events output rules are the same as if a standard transfer function had been called.
  - i.e. an external viewer MUST still be able to query the balance via a standard function and it MUST be identical to the balance as determined by `TransferSingle` and `TransferBatch` events alone.
- If the receiver is a contract the `KIP37TokenReceiver` or `ERC1155TokenReceiver` hooks still need to be called on it and the return values respected the same as if a standard transfer function had been called.
  - However while the `safeTransferFrom` or `safeBatchTransferFrom` functions MUST revert if a receiving contract does not implement the KIP37TokenReceiver or ERC1155TokenReceiver interface, a non-standard function MAY proceed with the transfer.
  - See [Implementation specific transfer API rules](#implementation-specific-transfer-api-rules).

#### Rules

##### **_safeTransferFrom rules:_**

- Caller must be approved to manage the tokens being transferred out of the `_from` account (see “Approval” section).
- MUST revert if `_to` is the zero address.
- MUST revert if balance of holder for token `_id` is lower than the `_value` sent to the recipient.
- MUST revert on any other error.
- MUST emit the `TransferSingle` event to reflect the balance change (see [TransferSingle and TransferBatch event rules](#transfersingle-and-transferbatch-event-rules) section).
- After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onKIP37Received` or `onERC1155Received` on `_to` and act appropriately (see [onKIP37Received rules](#onkip37received-rules) section).
  - The `_data` argument provided by the sender for the transfer MUST be passed with its contents unaltered to the `onKIP37Received` or `onERC1155Received` hook function via its `_data` argument.

##### **_safeBatchTransferFrom rules:_**

- Caller must be approved to manage all the tokens being transferred out of the `_from` account (see “Approval” section).
- MUST revert if `_to` is the zero address.
- MUST revert if the length of `_ids` is not the same as the length of `_values`.
- MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
- MUST revert on any other error.
- MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see [TransferSingle and TransferBatch event rules](#transfersingle-and-transferbatch-event-rules) section).
- The balance changes and events MUST occur in the array order they were submitted (\_ids[0]/\_values[0] before \_ids[1]/\_values[1], etc).
- After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onKIP37Received`, `onKIP37BatchReceived`, `onERC1155Received` or `onERC1155BatchReceived` on `_to` and act appropriately (see [onKIP37Received rules](#onkip37received-rules) and [onKIP37BatchReceived rules](#onkip37batchreceived-rules) section).
  - The `_data` argument provided by the sender for the transfer MUST be passed with its contents unaltered to the `KIP37TokenReceiver` or `ERC1155TokenReceiver` hook function(s) via their `_data` argument.

##### **_TransferSingle and TransferBatch event rules:_**

- `TransferSingle` SHOULD be used to indicate a single balance transfer has occurred between a `_from` and `_to` pair.
  - It MAY be emitted multiple times to indicate multiple balance changes in the transaction, but note that `TransferBatch` is designed for this to reduce gas consumption.
  - The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
  - The `_from` argument MUST be the address of the holder whose balance is decreased.
  - The `_to` argument MUST be the address of the recipient whose balance is increased.
  - The `_id` argument MUST be the token type being transferred.
  - The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
  - When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address). See [Minting-creating and burning-destroying rules](#minting-creating-and-burning-destroying-rules).
  - When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address). See [Minting-creating and burning-destroying rules](#minting-creating-and-burning-destroying-rules).
- `TransferBatch` SHOULD be used to indicate multiple balance transfers have occurred between a `_from` and `_to` pair.
  - It MAY be emitted with a single element in the list to indicate a singular balance change in the transaction, but note that `TransferSingle` is designed for this to reduce gas consumption.
  - The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
  - The `_from` argument MUST be the address of the holder whose balance is decreased for each entry pair in `_ids` and `_values`.
  - The `_to` argument MUST be the address of the recipient whose balance is increased for each entry pair in `_ids` and `_values`.
  - The `_ids` array argument MUST contain the ids of the tokens being transferred.
  - The `_values` array argument MUST contain the number of token to be transferred for each corresponding entry in `_ids`.
  - `_ids` and `_values` MUST have the same length.
  - When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address). See [Minting-creating and burning-destroying rules](#minting-creating-and-burning-destroying-rules).
  - When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address). See [Minting-creating and burning-destroying rules](#minting-creating-and-burning-destroying-rules).
- The total value transferred from address `0x0` minus the total value transferred to `0x0` observed via the `TransferSingle` and `TransferBatch` events MAY be used by clients and exchanges to determine the “circulating supply” for a given token ID.
- To broadcast the existence of a token ID with no initial balance, the contract SHOULD emit the `TransferSingle` event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_value` of 0.
- All `TransferSingle` and `TransferBatch` events MUST be emitted to reflect all the balance changes that have occurred before any call(s) to `onKIP37Received`, `onKIP37BatchReceived`, `onERC1155Received` or `onERC1155BatchReceived`.
  - To make sure event order is correct in the case of valid re-entry (e.g. if a receiver contract forwards tokens on receipt) state balance and events balance MUST match before calling an external contract.

##### **_onKIP37Received rules:_**

- The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).

* The `_from` argument MUST be the address of the holder whose balance is decreased.
  - `_from` MUST be 0x0 for a mint.
* The `_id` argument MUST be the token type being transferred.
* The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
* The `_data` argument MUST contain the information provided by the sender for the transfer with its contents unaltered.
  - i.e. it MUST pass on the unaltered `_data` argument sent via the `safeTransferFrom` or `safeBatchTransferFrom` call for this transfer.
* The recipient contract MAY accept an increase of its balance by returning the acceptance magic value `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)"))`
  - If the return value is `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)"))` the transfer MUST be completed or MUST revert if any other conditions are not met for success.
* The recipient contract MAY reject an increase of its balance by calling revert.
  - If the recipient contract throws/reverts the transaction MUST be reverted.
* If the return value is anything other than `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)"))` the transaction MUST be reverted.
* `onKIP37Received` (and/or `onKIP37BatchReceived`) MAY be called multiple times in a single transaction and the following requirements must be met:
  - All callbacks represent mutually exclusive balance changes.
  - The set of all calls to `onKIP37Received` and `onKIP37BatchReceived` describes all balance changes that occurred during the transaction in the order submitted.
* A contract MAY skip calling the `onKIP37Received` hook function if the transfer operation is transferring the token to itself.

##### **_onKIP37BatchReceived rules:_**

- The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).

* The `_from` argument MUST be the address of the holder whose balance is decreased.
  - `_from` MUST be 0x0 for a mint.
* The `_ids` argument MUST be the list of tokens being transferred.
* The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in `_ids`) the holder balance is decreased by and match what the recipient balance is increased by.
* The `_data` argument MUST contain the information provided by the sender for the transfer with its contents unaltered.
  - i.e. it MUST pass on the unaltered `_data` argument sent via the `safeBatchTransferFrom` call for this transfer.
* The recipient contract MAY accept an increase of its balance by returning the acceptance magic value `bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))`
  - If the return value is `bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))` the transfer MUST be completed or MUST revert if any other conditions are not met for success.
* The recipient contract MAY reject an increase of its balance by calling revert.
  - If the recipient contract throws/reverts the transaction MUST be reverted.
* If the return value is anything other than `bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))` the transaction MUST be reverted.
* `onKIP37BatchReceived` (and/or `onKIP37Received`) MAY be called multiple times in a single transaction and the following requirements must be met:
  - All callbacks represent mutually exclusive balance changes.
  - The set of all calls to `onKIP37Received` and `onKIP37BatchReceived` describes all balance changes that occurred during the transaction in the order submitted.
* A contract MAY skip calling the `onKIP37BatchReceived` hook function if the transfer operation is transferring the token(s) to itself.

##### **_KIP37TokenReceiver KIP-13 rules:_**

- The implementation of the KIP-13 `supportsInterface` function SHOULD be as follows:
  ```solidity
  function supportsInterface(bytes4 interfaceID) external view returns (bool) {
      return  interfaceID == 0x01ffc9a7 ||    // KIP-13 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
              interfaceID == 0x7cc2d017;      // KIP-37 `KIP37TokenReceiver` support (i.e. `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
  }
  ```
- The implementation MAY differ from the above but:
  - It MUST return the constant value `true` if `0x01ffc9a7` is passed through the `interfaceID` argument. This signifies KIP-13 support.
  - It MUST return the constant value `true` if `0x7cc2d017` is passed through the `interfaceID` argument. This signifies KIP-37 `KIP37TokenReceiver` support.
  - It MUST NOT consume more than 10,000 gas.
    - This keeps it below the KIP-13 requirement of 30,000 gas, reduces the gas reserve needs and minimises possible side-effects of gas exhaustion during the call.

##### **_Implementation specific transfer API rules:_**

- If an implementation specific API function is used to transfer KIP-37 token(s) to a contract, the `safeTransferFrom` or `safeBatchTransferFrom` (as appropriate) rules MUST still be followed if the receiver implements the `KIP37TokenReceiver` interface. If it does not the non-standard implementation SHOULD revert but MAY proceed.
- An example:
  1. An approved user calls a function such as `function myTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values);`.
  2. `myTransferFrom` updates the balances for `_from` and `_to` addresses for all `_ids` and `_values`.
  3. `myTransferFrom` emits `TransferBatch` with the details of what was transferred from address `_from` to address `_to`.
  4. `myTransferFrom` checks if `_to` is a contract address and determines that it is so (if not, then the transfer can be considered successful).
  5. `myTransferFrom` calls `onKIP37BatchReceived` on `_to` and it reverts or returns an unknown value (if it had returned `bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))` the transfer can be considered successful).
  6. At this point `myTransferFrom` SHOULD revert the transaction immediately as receipt of the token(s) was not explicitly accepted by the `onKIP37BatchReceived` function.
  7. If however `myTransferFrom` wishes to continue it MUST call `supportsInterface(0x7cc2d017)` on `_to` and if it returns the constant value `true` the transaction MUST be reverted, as it is now known to be a valid receiver and the previous acceptance step failed.
     - NOTE: You could have called `supportsInterface(0x7cc2d017)` at a previous step if you wanted to gather and act upon that information earlier, such as in a hybrid standards scenario.
  8. If the above call to `supportsInterface(0x7cc2d017)` on `_to` reverts or returns a value other than the constant value `true` the `myTransferFrom` function MAY consider this transfer successful.
     - **NOTE**: this MAY result in unrecoverable tokens if sent to an address that does not expect to receive KIP-37 tokens.
- The above example is not exhaustive but illustrates the major points (and shows that most are shared with `safeTransferFrom` and `safeBatchTransferFrom`):
  - Balances that are updated MUST have equivalent transfer events emitted.
  - A receiver address has to be checked if it is a contract and if so relevant `KIP37TokenReceiver` hook function(s) have to be called on it.
  - Balances (and events associated) that are referenced in a call to an `KIP37TokenReceiver` hook MUST be updated (and emitted) before the `KIP37TokenReceiver` hook is called.
  - The return values of the `KIP37TokenReceiver` hook functions that are called MUST be respected if they are implemented.
  - Only non-standard transfer functions MAY allow tokens to be sent to a recipient contract that does NOT implement the necessary `KIP37TokenReceiver` hook functions. `safeTransferFrom` and `safeBatchTransferFrom` MUST revert in that case (unless it is a hybrid standards implementation see "Backwards Compatibility").

##### **_Minting-creating and burning-destroying rules:_**

- 'create' means creating a new kind of token by assigning a new token ID.
- 'mint' means issuing additional tokens that have already been created.
- When creating tokens, the total supply of the token ID must be increased by initial supply.
- When minting tokens, the total supply of the token ID must be increased by minted quantity.
- When burning tokens, the total supply of the token ID must be decreased by burned quantity.
- A mint/create operation is essentially a specialized transfer and MUST follow these rules:
  - To broadcast the existence of a token ID with no initial balance, the contract SHOULD emit the `TransferSingle` event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_value` of 0.
  - The [TransferSingle and TransferBatch event rules](#transfersingle-and-transferbatch-event-rules) MUST be followed as appropriate for the mint(s) (i.e., singles or batches) however the `_from` argument MUST be set to `0x0` (i.e., zero address) to flag the transfer as a mint to contract observers.
    - **NOTE:** This includes tokens that are given an initial balance in the contract. The balance of the contract MUST also be able to be determined by events alone meaning initial contract balances (e.g., in construction) MUST emit events to reflect those balances too.
- A burn/destroy operation is essentially a specialized transfer and MUST follow these rules:
  - The [TransferSingle and TransferBatch event rules](#transfersingle-and-transferbatch-event-rules) MUST be followed as appropriate for the burn(s) (i.e. singles or batches) however the `_to` argument MUST be set to `0x0` (i.e., zero address) to flag the transfer as a burn to contract observers.
  - When burning/destroying, you do not have to actually transfer to `0x0` (that is implementation specific), only the `_to` argument in the event MUST be set to `0x0` as above.
- The total value transferred from address `0x0` minus the total value transferred to `0x0` observed via the `TransferSingle` and `TransferBatch` events MAY be used by clients and exchanges to determine the "circulating supply" for a given token ID.
- As mentioned above mint/create and burn/destroy operations are specialized transfers and so will likely be accomplished with custom transfer functions rather than `safeTransferFrom` or `safeBatchTransferFrom`. If so the [Implementation specific transfer API rules](#implementation-specific-transfer-api-rules) section would be appropriate.
  - Even in a non-safe API and/or hybrid standards case the above event rules MUST still be adhered to when minting/creating or burning/destroying.
- A contract MAY skip calling the `KIP37TokenReceiver` hook function(s) if the mint operation is transferring the token(s) to itself. In all other cases the `KIP37TokenReceiver` rules MUST be followed as appropriate for the implementation (i.e., safe, custom and/or hybrid).

##### magic value calculation

- the keccak256 generated constants for the various magic values (these MAY be used by implementation):

```solidity
bytes4 constant public KIP37_KIP13 = 0x6433ca1f; // KIP-13 identifier for the main token standard.
bytes4 constant public KIP37_KIP13_TOKENRECEIVER = 0x7cc2d017; // KIP-13 identifier for the `KIP37TokenReceiver` support (i.e. `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
bytes4 constant public KIP37_ACCEPTED = 0xe78b3325; // Return value from `onKIP37Received` call if a contract accepts receipt (i.e `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)"))`).
bytes4 constant public KIP37_BATCH_ACCEPTED = 0x9b49e332; // Return value from `onKIP37BatchReceived` call if a contract accepts receipt (i.e `bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
```

### Metadata

The URI value allows for ID substitution by clients. If the string `{id}` exists in any URI, clients MUST replace this with the actual token ID in hexadecimal form. This allows for a large number of tokens to use the same on-chain string by defining a URI once, for that large number of tokens.

- The string format of the substituted hexadecimal ID MUST be lowercase alphanumeric: `[0-9a-f]` with no 0x prefix.
- The string format of the substituted hexadecimal ID MUST be leading zero padded to 64 hex characters length if necessary.

Example of such a URI: `https://token-cdn-domain/{id}.json` would be replaced with `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json` if the client is referring to token ID 314592/0x4CCE0.

#### Metadata Extension

The optional `KIP37Metadata_URI` extension can be identified with the (KIP-13 Standard Interface Detection)[https://kips.klaytn.com/KIPs/kip-13].

If the optional `KIP37Metadata_URI` extension is included:

- The KIP-13 `supportsInterface` function MUST return the constant value `true` if `0x0e89341c` is passed through the `interfaceID` argument.
- _Changes_ to the URI MUST emit the `URI` event if the change can be expressed with an event (i.e. it isn't dynamic/programmatic).
  - An implementation MUST emit the `URI` event during a creation operation if `URI` of the new token type should be propagated to observers.
  - An implementation MAY emit the `URI` event during a mint operation but it is NOT mandatory. An observer MAY fetch the metadata uri at mint time from the `uri` function if it was not emitted.
- The `uri` function SHOULD be used to retrieve values if no event was emitted.
- The `uri` function MUST return the same value as the latest event for an `_id` if it was emitted.
- The `uri` function MUST NOT be used to check for the existence of a token as it is possible for an implementation to return a valid string even if the token does not exist.

```solidity
pragma solidity 0.5.6;

/**
    Note: The KIP-13 identifier for this interface is 0x0e89341c.
*/
interface KIP37Metadata_URI {
    /**
        @notice A distinct Uniform Resource Identifier (URI) for a given token.
        @dev URIs are defined in RFC 3986.
        The URI MUST point to a JSON file that conforms to the "KIP-37 Metadata URI JSON Schema".
        @return URI string
    */
    function uri(uint256 _id) external view returns (string memory);
}
```

#### KIP-37 Metadata URI JSON Schema

This JSON schema is loosely based on the "KIP-17 Metadata JSON Schema", but includes optional formatting to allow for ID substitution by clients. If the string `{id}` exists in any JSON value, it MUST be replaced with the actual token ID, by all client software that follows this standard.

- The string format of the substituted hexadecimal ID MUST be lowercase alphanumeric: `[0-9a-f]` with no 0x prefix.
- The string format of the substituted hexadecimal ID MUST be leading zero padded to 64 hex characters length if necessary.

```json
{
  "title": "Token Metadata",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "Identifies the asset to which this token represents"
    },
    "decimals": {
      "type": "integer",
      "description": "The number of decimal places that the token amount should display - e.g. 18, means to divide the token amount by 1000000000000000000 to get its user representation."
    },
    "description": {
      "type": "string",
      "description": "Describes the asset to which this token represents"
    },
    "image": {
      "type": "string",
      "description": "A URI pointing to a resource with mime type image/* representing the asset to which this token represents. Consider making any images at a width between 320 and 1080 pixels and aspect ratio between 1.91:1 and 4:5 inclusive."
    },
    "properties": {
      "type": "object",
      "description": "Arbitrary properties. Values may be strings, numbers, object or arrays."
    }
  }
}
```

An example of a KIP-37 Metadata JSON file follows. The properties array proposes some SUGGESTED formatting for token-specific display properties and metadata.

```json
{
  "name": "Asset Name",
  "decimals": 18,
  "description": "Lorem ipsum...",
  "image": "https://s3.amazonaws.com/your-bucket/images/{id}.png",
  "properties": {
    "simple_property": "example value",
    "rich_property": {
      "name": "Name",
      "value": "123",
      "display_value": "123 Example Value",
      "class": "emphasis",
      "css": {
        "color": "#ffffff",
        "font-weight": "bold",
        "text-decoration": "underline"
      }
    },
    "array_property": {
      "name": "Name",
      "value": [1, 2, 3, 4],
      "class": "emphasis"
    }
  }
}
```

##### Localization

Metadata localization should be standardized to increase presentation uniformity across all languages. As such, a simple overlay method is proposed to enable localization. If the metadata JSON file contains a `localization` attribute, its content MAY be used to provide localized values for fields that need it. The `localization` attribute should be a sub-object with three attributes: `uri`, `default` and `locales`. If the string `{locale}` exists in any URI, it MUST be replaced with the chosen locale by all client software.

##### JSON Schema

```json
{
  "title": "Token Metadata",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "Identifies the asset to which this token represents"
    },
    "decimals": {
      "type": "integer",
      "description": "The number of decimal places that the token amount should display - e.g. 18, means to divide the token amount by 1000000000000000000 to get its user representation."
    },
    "description": {
      "type": "string",
      "description": "Describes the asset to which this token represents"
    },
    "image": {
      "type": "string",
      "description": "A URI pointing to a resource with mime type image/* representing the asset to which this token represents. Consider making any images at a width between 320 and 1080 pixels and aspect ratio between 1.91:1 and 4:5 inclusive."
    },
    "properties": {
      "type": "object",
      "description": "Arbitrary properties. Values may be strings, numbers, object or arrays."
    },
    "localization": {
      "type": "object",
      "required": ["uri", "default", "locales"],
      "properties": {
        "uri": {
          "type": "string",
          "description": "The URI pattern to fetch localized data from. This URI should contain the substring `{locale}` which will be replaced with the appropriate locale value before sending the request."
        },
        "default": {
          "type": "string",
          "description": "The locale of the default data within the base JSON"
        },
        "locales": {
          "type": "array",
          "description": "The list of locales for which data is available. These locales should conform to those defined in the Unicode Common Locale Data Repository (http://cldr.unicode.org/)."
        }
      }
    }
  }
}
```

##### Localized Sample

Base URI:

```json
{
  "name": "Advertising Space",
  "description": "Each token represents a unique Ad space in the city.",
  "localization": {
    "uri": "ipfs://QmWS1VAdMD353A6SDk9wNyvkT14kyCiZrNDYAad4w1tKqT/{locale}.json",
    "default": "en",
    "locales": ["en", "es", "fr"]
  }
}
```

es.json:

```json
{
  "name": "Espacio Publicitario",
  "description": "Cada token representa un espacio publicitario único en la ciudad."
}
```

fr.json:

```json
{
  "name": "Espace Publicitaire",
  "description": "Chaque jeton représente un espace publicitaire unique dans la ville."
}
```

### Minting Extension

The **minting extension** is OPTIONAL for KIP-37 smart contracts. This allows your contract to create and mint a new token. Here, 'create' means creating a new kind of token by assigning a new token ID, and 'mint' means issuing additional tokens that have already been created.

The optional `KIP37Mintable` extension can be identified with the (KIP-13 Standard Interface Detection)[https://kips.klaytn.com/KIPs/kip-13].

If the optional `KIP37Mintable` extension is included:

- The KIP-13 `supportsInterface` function MUST return the constant value `true` if `0x84aec3b9` is passed through the `interfaceID` argument.
- The `create` function is used to create a new token allocated with a new token id.
  - An implementation MUST emit the `URI` event during a create operation if the created token has its own metadata.
- When creating tokens, the total supply of the token ID must be increased by initial supply.
- When minting tokens, the total supply of the token ID must be increased by minted quantity.
- When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address). See [Minting-creating and burning-destroying rules](#minting-creating-and-burning-destroying-rules).

```solidity
pragma solidity 0.5.6;

/// @title KIP-37 Multi Token Standard, optional minting extension
///  Note: the KIP-13 identifier for this interface is 0x84aec3b9.
interface IKIP37Mintable {
    /// @notice Creates a new token type and assigns _initialSupply to the minter.
    /// @dev Throws if `msg.sender` is not allowed to create.
    ///   Throws if the token id is already used.
    /// @param _id The token id to create.
    /// @param _initialSupply The amount of tokens being minted.
    /// @param _uri The token URI of the created token.
    /// @return A boolean that indicates if the operation was successful.
    function create(
        uint256 _id,
        uint256 _initialSupply,
        string calldata _uri
    ) external returns (bool);

    /// @notice Mints token and assigns the token according to the variables `_to` and `_quantity`.
    /// @dev Throws if `msg.sender` is not allowed to mint.
    ///   MUST emit an event `TransferSingle`.
    /// @param _id The token id to mint.
    /// @param _to The address that will receive the minted token.
    /// @param _quantity The quantity of token being minted.
    function mint(
        uint256 _id,
        address _to,
        uint256 _quantity
    ) external;

    /// @notice Mints tokens in a batch and assigns the tokens according to the variables `_to` and `_quantities`.
    /// @dev Throws if `msg.sender` is not allowed to mint.
    ///   MUST emit an event `TransferSingle` or `TransferBatch`.
    /// @param _id The token id to mint.
    /// @param _toList The list of addresses that will receive the minted tokens.
    /// @param _quantities The list of quantities of tokens being minted.
    function mintBatch(
        uint256 _id,
        address[] calldata _toList,
        uint256[] calldata _quantities
    ) external;
}
```

### Burning Extension

The **burning extension** is OPTIONAL for KIP-37 smart contracts. This allows your contract to burn tokens.

The optional `KIP37Burnable` extension can be identified with the (KIP-13 Standard Interface Detection)[https://kips.klaytn.com/KIPs/kip-13].

If the optional `KIP37Burnable` extension is included, the following features MUST be implemented:

- The KIP-13 `supportsInterface` function MUST return the constant value `true` if `0x9e094e9e` is passed through the `interfaceID` argument.
- When burning tokens, the total supply of the token ID must be decreased by burned quantity.
- When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address). See [Minting-creating and burning-destroying rules](#minting-creating-and-burning-destroying-rules).

```solidity
pragma solidity 0.5.6;

/// @title KIP-37 Multi Token Standard, optional burning extension
///  Note: the KIP-13 identifier for this interface is 0x9e094e9e.
interface IKIP37Burnable {
    /// @notice Burns specific KIP37 tokens.
    /// @dev Throws if `msg.sender` is not allowed to burn the token.
    ///   Throws if `_account` does not have `_value` tokens for `_id`.
    /// @param _account The account that owns tokens.
    /// @param _id The token id to burn.
    /// @param _value The token amount to burn.
    function burn(
        address _account,
        uint256 _id,
        uint256 _value
    ) external;

    /// @notice Burns multiple KIP37 tokens.
    /// @dev Throws if `msg.sender` is not allowed to burn the tokens.
    ///   Throws if `_account` does not have tokens to be burnt.
    /// @param _account The account that owns tokens.
    /// @param _ids The list of the token ids to burn.
    /// @param _values The list of the token amounts to burn.
    function burnBatch(
        address _account,
        uint256[] calldata _ids,
        uint256[] calldata _values
    ) external;
}
```

### Pausing Extension

The **pausing extension** is OPTIONAL for KIP-37 smart contracts. This allows your contract or specific token to be suspended from transferring.

The optional `KIP37Pausable` extension can be identified with the (KIP-13 Standard Interface Detection)[https://kips.klaytn.com/KIPs/kip-13].

If the optional `KIP37Pausable` extension is included:

- The KIP-13 `supportsInterface` function MUST return the constant value `true` if `0x0e8ffdb7` is passed through the `interfaceID` argument.

```solidity
pragma solidity 0.5.6;

/// @title KIP-37 Multi Token Standard, optional pausing extension
///  Note: the KIP-13 identifier for this interface is 0x0e8ffdb7.
interface IKIP37Pausable {
    /// @notice Checks whether the whole contract is paused.
    /// @return True if the contract is paused, false otherwise.
    function paused() external view returns (bool);

    /// @notice Pauses actions related to transfer and approval in the contract.
    /// @dev Throws if `msg.sender` is not allowed to pause.
    ///   Throws if the contract is paused.
    function pause() external;

    /// @notice Resumes from the paused state of the contract.
    /// @dev Throws if `msg.sender` is not allowed to unpause.
    ///   Throws if the contract is not paused.
    function unpause() external;

    /// @notice Checks whether the specific token is paused.
    /// @return True if the specific token is paused, false otherwise
    function paused(uint256 _id) external view returns (bool);

    /// @notice Pauses actions related to transfer and approval of the specific token.
    /// @dev Throws if `msg.sender` is not allowed to pause.
    ///   Throws if the specific token is paused.
    function pause(uint256 _id) external;

    /// @notice Resumes from the paused state of the specific token.
    /// @dev Throws if `msg.sender` is not allowed to unpause.
    ///   Throws if the specific token is not paused.
    function unpause(uint256 _id) external;
}
```

### Approval

The function `setApprovalForAll` allows an operator to manage one's entire set of tokens on behalf of the approver.
The counterpart `isApprovedForAll` provides introspection into any status set by `setApprovalForAll`.

An owner SHOULD be assumed to always be able to operate on their own tokens regardless of approval status, so SHOULD NOT have to call `setApprovalForAll` to approve themselves as an operator before they can operate on them.

## Rationale

### Metadata Choices

The `symbol` function (found in the KIP-7 and KIP-17 standards) was not included as we do not believe this is a globally useful piece of data to identify a generic virtual item / asset and are also prone to collisions. Short-hand symbols are used in tickers and currency trading, but they aren't as useful outside of that space.

The `name` function (for human-readable asset names, on-chain) was removed from the standard to allow the Metadata JSON to be the definitive asset name and reduce duplication of data. This also allows localization for names, which would otherwise be prohibitively expensive if each language string was stored on-chain, not to mention bloating the standard interface. While this decision may add a small burden on implementers to host a JSON file containing metadata, we believe any serious implementation of KIP-37 will already utilize JSON Metadata.

### Upgrades

The requirement to emit `TransferSingle` or `TransferBatch` on balance change implies that a valid implementation of KIP-37 redeploying to a new contract address MUST emit events from the new contract address to replicate the deprecated contract final state. It is valid to only emit a minimal number of events to reflect only the final balance and omit all the transactions that led to that state. The event emit requirement is to ensure that the current state of the contract can always be traced only through events. To alleviate the need to emit events when changing contract address, consider using the proxy pattern. This will also have the added benefit of providing a stable contract address for users.

### Design decision: Supporting non-batch

The standard supports `safeTransferFrom` and `onKIP37Received` functions because they are significantly cheaper for single token-type transfers, which is arguably a common use case.

### Design decision: Safe transfers only

The standard only supports safe-style transfers, making it possible for receiver contracts to depend on `onKIP37Received` or `onKIP37BatchReceived` function to be always called at the end of a transfer.

### Guaranteed log trace

The KIP-37 standard guarantees that event logs emitted by the smart contract will provide enough data to create an accurate record of all current token balances. A database or explorer may listen to events and be able to provide indexed and categorized searches of every KIP-37 token in the contract.

### Approval

The function `setApprovalForAll` allows an operator to manage one's entire set of tokens on behalf of the approver. It enables frictionless interaction with exchange and trade contracts.

Restricting approval to a certain set of token IDs, quantities or other rules MAY be done with an additional interface or an external contract. The rationale is to keep the KIP-37 standard as generic as possible for all use-cases without imposing a specific approval scheme on implementations that may not need it.

## Backwards Compatibility

There have been requirements during the design discussions to have this standard be compatible with existing standards when sending to contract addresses, specifically KIP-17 at time of writing.
To cater for this scenario, there is some leeway with the revert logic should a contract not implement the `KIP37TokenReceiver` as per [Safe Transfer Rules](#safe-transfer-rules) section above, specifically "Scenario#3 : The receiver does not implement the necessary `KIP37TokenReceiver` interface function(s)".

Hence in a hybrid KIP-37 contract implementation an extra call MUST be made on the recipient contract and checked before any hook calls to `onKIP37Received` or `onKIP37BatchReceived` are made.
The order of operation MUST therefore be:

1. The implementation MUST call the function `supportsInterface(0x7cc2d017)` on the recipient contract, providing at least 10,000 gas.
2. If the function call succeeds and the return value is the constant value `true` the implementation proceeds as a regular KIP-37 implementation, with the call(s) to the `onKIP37Received` or `onKIP37BatchReceived` hooks and rules associated.
3. If the function call fails or the return value is NOT the constant value `true` the implementation can assume the recipient contract is not a `KIP37TokenReceiver` and follow its other standard's rules for transfers.

## Usage

This standard can be used to represent multiple token types for an entire domain. Both fungible and non-fungible tokens can be stored in the same smart-contract.

### Batch Transfers

The `safeBatchTransferFrom` function allows for batch transfers of multiple token IDs and values. The design of KIP-37 makes batch transfers possible without the need for a wrapper contract, as with existing token standards. This reduces gas costs when more than one token type is included in a batch transfer, as compared to single transfers with multiple transactions.

Another advantage of standardized batch transfers is the ability for a smart contract to respond to the batch transfer in a single operation using `onKIP37BatchReceived`.

It is RECOMMENDED that clients and wallets sort the token IDs and associated values (in ascending order) when posting a batch transfer, as some KIP-37 implementations offer significant gas cost savings when IDs are sorted. See [Horizon Games - Multi-Token Standard](https://github.com/horizon-games/multi-token-standard) "packed balance" implementation for an example of this.

### Batch Balance

The `balanceOfBatch` function allows clients to retrieve balances of multiple owners and token IDs with a single call.

### Enumerating from events

In order to keep storage requirements light for contracts implementing KIP-37, enumeration (discovering the IDs and values of tokens) must be done using event logs. It is RECOMMENDED that clients such as exchanges and blockchain explorers maintain a local database containing the token ID, Supply, and URI at the minimum. This can be built from each TransferSingle, TransferBatch, and URI event, starting from the block the smart contract was deployed until the latest block.

KIP-37 contracts must therefore carefully emit `TransferSingle` or `TransferBatch` events in any instance where tokens are created, minted, transferred or destroyed.

### Non-Fungible Tokens

The following strategies are examples of how you MAY mix fungible and non-fungible tokens together in the same contract. The standard does NOT mandate how an implementation must do this.

##### Split ID bits

The top 128 bits of the uint256 `_id` parameter in any KIP-37 function MAY represent the base token ID, while the bottom 128 bits MAY represent the index of the non-fungible to make it unique.

Non-fungible tokens can be interacted with using an index based accessor into the contract/token data set. Therefore to access a particular token set within a mixed data contract and a particular non-fungible within that set, `_id` could be passed as `<uint128: base token id><uint128: index of non-fungible>`.

To identify a non-fungible set/category as a whole (or a fungible) you COULD just pass in the base id via the `_id` argument as `<uint128: base token id><uint128: zero>`. If your implementation uses this technique this naturally means the index of a non-fungible SHOULD be 1-based.

Inside the contract code the two pieces of data needed to access the individual non-fungible can be extracted with uint128(~0) and the same mask shifted by 128.

```solidity
uint256 baseTokenNFT = 12345 << 128;
uint128 indexNFT = 50;

uint256 baseTokenFT = 54321 << 128;

balanceOf(baseTokenNFT, msg.sender); // Get balance of the base token for non-fungible set 12345 (this MAY be used to get a balance of the user for all of this token set if the implementation wishes as a convenience).
balanceOf(baseTokenNFT + indexNFT, msg.sender); // Get balance of the token at index 50 for non-fungible set 12345 (should be 1 if user owns the individual non-fungible token or 0 if they do not).
balanceOf(baseTokenFT, msg.sender); // Get balance of the fungible base token 54321.
```

Note that 128 is an arbitrary number, an implementation MAY choose how they would like this split to occur as suitable for their use case. An observer of the contract would simply see events showing balance transfers and mints happening and MAY track the balances using that information alone.
For an observer to be able to determine type (non-fungible or fungible) from an ID alone they would have to know the split ID bits format on an implementation by implementation basis.

##### Natural Non-Fungible tokens

Another simple way to represent non-fungibles is to allow a maximum value of 1 for each non-fungible token. This would naturally mirror the real world, where unique items have a quantity of 1 and fungible items have a quantity greater than 1.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
