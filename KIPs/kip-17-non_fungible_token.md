---
kip: 17
title: Non-fungible Token Standard
author: Junghyun Colin Kim <colin.kim@groundx.xyz>
discussions-to: https://github.com/klaytn/kips/issues/17
status: Draft
type: Standards Track
category: Token
created: 2020-03-04
requires: 13
---

## Simple Summary
A standard interface for non-fungible tokens (NFTs), also known as deeds.

## Abstract
The following standard allows for the implementation of a standard API for NFTs within smart contracts. This standard provides basic functionality to track and transfer NFTs.

We considered use cases of NFTs being owned and transacted by individuals as well as consignment to third party brokers/wallets/auctioneers ("operators"). NFTs can represent ownership over digital or physical assets. We considered a diverse universe of assets, and we know you will dream up many more:

- Physical property — houses, unique artwork
- Virtual collectibles — unique pictures of kittens, collectible cards
- "Negative value" assets — loans, burdens and other responsibilities

In general, all houses are distinct and no two kittens are alike. NFTs are *distinguishable* and you must track the ownership of each one separately.

## Motivation
A standard interface allows wallet/broker/auction applications to work with any NFT on Klaytn. We provide simple KIP-17 smart contracts as well as contracts that track an *arbitrarily large* number of NFTs. Additional applications are discussed below.

## Specification
This document is heavily derived from [ERC-721](https://eips.ethereum.org/EIPS/eip-721) written by William Entriken, Dieter Shirley, Jacob Evans, and Nastassia Sachs.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

### Differences from ERC-721
This section describes the differences between KIP-17 and ERC-721. 

- Every token transfer/mint/burn MUST be tracked by event logs. This means that a Transfer event MUST be emitted for any action related to transfer/mint/burn.
- KIP-17 also supports the wallet interface of ERC-721 (`ERC721TokenReceiver`) to be compliant with ERC-721.
- More optional extensions are defined (minting extension, minting with URI extension, burning extension, and pausing extension).

### KIP-13 Identifiers
The below table shows KIP-13 identifiers for interfaces defined in this proposal.

|Interface|KIP-13 Identifier|
|---|---|
|[KIP17](#kip17-interface)|0x80ac58cd|
|[KIP17TokenReceiver](#wallet-interface-kip17tokenreceiver)|0x6745782b|
|[ERC721TokenReceiver](#wallet-interface-kip17tokenreceiver)|0x150b7a02|
|[KIP17Metadata](#metadata-extension)|0x5b5e139f|
|[KIP17Enumerable](#enumeration-extension)|0x780e9d63|
|[KIP17Mintable](#minting-extension)|0xeab83e20|
|[KIP17MetadataMintable](#minting-with-uri-extension)|0x50bb4e7f|
|[KIP17Burnable](#burning-extension)|0x42966c68|
|[KIP17Pausable](#pausing-extension)|0x4d5507ff|

### KIP17 Interface
```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard
///  Note: the KIP-13 identifier for this interface is 0x80ac58cd.
interface KIP17 {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). At the time of any transfer, the approved address for 
    /// that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onKIP17Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param _data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
```

### Wallet Interface (KIP17TokenReceiver)
A wallet/broker/auction application MUST implement the **wallet interface** if it will accept safe transfers.

```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard, optional wallet interface
/// @dev Note: the KIP-13 identifier for this interface is 0x6745782b.
interface KIP17TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The KIP-17 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onKIP17Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}
```

To be compliant with ERC-721, KIP-17 also supports ERC721TokenReceiver. This makes the current ERC-721 implementation on Ethereum
can be easily migrated on to Klaytn without any modification.
```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard, optional ERC-721 wallet interface
/// @dev Note: the KIP-13 identifier for this interface is 0x150b7a02.
interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}
```

### Metadata Extension
The **metadata extension** is OPTIONAL for KIP-17 smart contracts (see "caveats", below). This allows your smart contract to be interrogated for its name and for details about the assets which your NFTs represent.

```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard, optional metadata extension.
///  Note: the KIP-13 identifier for this interface is 0x5b5e139f.
interface KIP17Metadata {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "KIP17
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string);
}
```

This is the "KIP17 Metadata JSON Schema" referenced above.

```json
{
    "title": "Asset Metadata",
    "type": "object",
    "properties": {
        "name": {
            "type": "string",
            "description": "Identifies the asset to which this NFT represents"
        },
        "description": {
            "type": "string",
            "description": "Describes the asset to which this NFT represents"
        },
        "image": {
            "type": "string",
            "description": "A URI pointing to a resource with mime type image/* representing the asset to which this NFT represents. Consider making any images at a width between 320 and 1080 pixels and aspect ratio between 1.91:1 and 4:5 inclusive."
        }
    }
}
```

### Enumeration Extension
The **enumeration extension** is OPTIONAL for KIP-17 smart contracts (see "caveats", below). This allows your contract to publish its full list of NFTs and make them discoverable.

```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard, optional enumeration extension
///  Note: the KIP-13 identifier for this interface is 0x780e9d63.
interface KIP17Enumerable {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}
```

### Minting Extension
The **minting extension** is OPTIONAL for KIP-17 smart contracts. This allows your contract to mint a new token.

```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard, optional minting extension
///  Note: the KIP-13 identifier for this interface is 0xeab83e20.
interface KIP17Mintable {
    /// @notice Create a new token
    /// @dev Throws if `msg.sender` is not allowed to mint
    /// @param _to The account that will receive the minted token
    /// @param _tokenId The token ID to mint
    /// @return True if the minting operation is successful, false otherwise
    function mint(address _to, uint256 _tokenId) public returns (bool);

    /// @notice Check the minting permission
    /// @param _account The account to check the minting permission
    /// @return True if the account has the minting permission, false otherwise
    function isMinter(address _account) public view returns (bool);

    /// @notice Give the minting permission to `_account`
    /// @dev Throws if `msg.sender` is not allowed to mint
    /// @param _account The account to be given the minting permission
    function addMinter(address _account) public;

    /// @notice Renounce the minter permission of `msg.sender`
    /// @dev Throws if `msg.sender` is not allowed to mint
    function renounceMinter() public;
}
```

### Minting with URI Extension
The **minting with URI extension** is OPTIONAL for KIP-17 smart contracts. This allows your contract to mint a new token with URI.

```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard, optional minting with URI extension
///  Note: the KIP-13 identifier for this interface is 0x50bb4e7f.
interface KIP17MetadataMintable {
    /// @notice Create a new token with the specified URI
    /// @dev Throws if `msg.sender` is not allowed to mint
    /// @param _to The account that will receive the minted token
    /// @param _tokenId The token ID to mint
    /// @param _tokenURI the token URI of the newly minted token
    /// @return True if the minting operation is succeeded, false otherwise
    function mintWithTokenURI(address _to, uint256 _tokenId, string memory _tokenURI) public returns (bool);
}
```

### Burning Extension
The **burning extension** is OPTIONAL for KIP-17 smart contracts. This allows your contract to burn a token.

```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard, optional burning extension
///  Note: KIP-13 identifier for this interface is 0x42966c68.
interface KIP17Burnable {
    /// @notice Destroy the specified token
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws  `_tokenId`
    ///  is not a valid NFT. 
    /// @param _tokenId The token ID to be burned
    function burn(uint256 _tokenId) public;
}
```


### Pausing Extension
The **pausing extension** is OPTIONAL for KIP-17 smart contracts. This allows your contract to be suspended from transferring.

```solidity
pragma solidity 0.4.24;

/// @title KIP-17 Non-Fungible Token Standard, optional pausing extension
///  Note: KIP-13 identifier for this interface is 0x4d5507ff.
interface KIP17Pausable {
    /// @dev This emits when the contract is paused
    event Paused(address _account);

    /// @dev This emits when the contract is unpaused
    event Unpaused(address _account);

    /// @notice Check whether the contract is paused
    /// @return True if the contract is paused, false otherwise    
    function paused() public view returns (bool);

    /// @notice Pause actions related to transfer and approve
    /// @dev Throws if `msg.sender` is not allowed to pause.
    ///   Throws if the contract is paused. 
    function pause() public;

    /// @notice Resume from the paused state of the contract
    /// @dev Throws if `msg.sender` is not allowed to unpause.
    ///   Throws if the contract is not paused. 
    function unpause() public;

    /// @notice Check the pausing permission
    /// @param _account The account to check the pausing permission
    /// @return True if the account has pausing permission, false otherwise
    function isPauser(address _account) public view returns (bool);

    /// @notice Give pausing permission to `_account`
    /// @dev Throws if `msg.sender` is not allowed to pause
    /// @param _account The account to be given the pausing permission
    function addPauser(address _account) public;

    /// @notice Renounce the pausing permission of `msg.sender`    
    /// @dev Throws if `msg.sender` is not allowed to pause
    function renouncePauser() public;
}
```

### Caveats

The 0.4.20 Solidity interface grammar is not expressive enough to document the KIP-17 standard. A contract which complies with KIP-17 MUST also abide by the following:

- Solidity issue #3412: The above interfaces include explicit mutability guarantees for each function. Mutability guarantees are, in order weak to strong: `payable`, implicit nonpayable, `view`, and `pure`. Your implementation MUST meet the mutability guarantee in this interface and you MAY meet a stronger guarantee. For example, a `payable` function in this interface may be implemented as nonpayble (no state mutability specified) in your contract. We expect a later Solidity release will allow your stricter contract to inherit from this interface, but a workaround for version 0.4.20 is that you can edit this interface to add stricter mutability before inheriting from your contract.
- Solidity issue #3419: A contract that implements `KIP17Metadata` or `KIP17Enumerable` SHALL also implement `KIP17`. KIP-17 implements the requirements of interface KIP-13.
- Solidity issue #2330: If a function is shown in this specification as `external` then a contract will be compliant if it uses `public` visibility. As a workaround for version 0.4.20, you can edit this interface to switch to `public` before inheriting from your contract.
- Solidity issues #3494, #3544: Use of `this.*.selector` is marked as a warning by Solidity, a future version of Solidity will not mark this as an error.

*If a newer version of Solidity allows the caveats to be expressed in code, then this KIP MAY be updated and the caveats removed, such will be equivalent to the original specification.*


## Rationale

There are many proposed uses of Klaytn smart contracts that depend on tracking distinguishable assets.
It is critical that these items are not "lumped together" as numbers in a ledger, but instead each asset must have its ownership individually and atomically tracked.
Regardless of the nature of these assets, the ecosystem will be stronger if we have a standardized interface that allows for cross-functional asset management and sales platforms.

**"NFT" Word Choice**

"NFT" was satisfactory to nearly everyone surveyed and is widely applicable to a broad universe of distinguishable digital assets. We recognize that "deed" is very descriptive for certain applications of this standard (notably, physical property).

*Alternatives considered: distinguishable asset, title, token, asset, equity, ticket*

**NFT Identifiers**

Every NFT is identified by a unique `uint256` ID inside the KIP-17 smart contract.
This identifying number SHALL NOT change for the life of the contract.
The pair `(contract address, uint256 tokenId)` will then be a globally unique and fully-qualified identifier for a specific asset on a Klaytn chain.
While some KIP-17 smart contracts may find it convenient to start with ID 0 and simply increment by one for each new NFT, callers SHALL NOT assume that ID numbers have any specific pattern to them, and MUST treat the ID as a "black box".
Also note that a NFTs MAY become invalid (be destroyed). Please see the enumerations functions for a supported enumeration interface.

The choice of `uint256` allows a wide variety of applications because UUIDs and sha3 hashes are directly convertible to `uint256`.

**Transfer Mechanism**

KIP-17 standardizes a safe transfer function `safeTransferFrom` (overloaded with and without a `bytes` parameter) and an unsafe function `transferFrom`. Transfers may be initiated by:

- The owner of an NFT
- The approved account of an NFT
- An authorized operator of the current owner of an NFT

Additionally, an authorized operator may set the approved account for an NFT. This provides a powerful set of tools for wallet, broker and auction applications to quickly use a *large* number of NFTs.

The transfer and accept functions' documentation only specify conditions when the transaction MUST throw. Your implementation MAY also throw in other situations. This allows implementations to achieve interesting results:

- **Disallow transfers if the contract is paused**
- **Blacklist certain address from receiving NFTs**
- **Disallow unsafe transfers** — `transferFrom` throws unless `_to` equals `msg.sender` or `countOf(_to)` is non-zero or was non-zero previously (because such cases are safe)
- **Charge a fee to both parties of a transaction** — require payment when calling `approve` with a non-zero `_approved` if it was previously the zero address, refund payment if calling `approve` with the zero address if it was previously a non-zero address, require payment when calling any transfer function, require transfer parameter `_to` to equal `msg.sender`, require transfer parameter `_to` to be the approved address for the NFT
- **Read only NFT registry** — always throw from `unsafeTransfer`, `transferFrom`, `approve` and `setApprovalForAll`

Failed transactions will throw. KIP-7 defined an `allowance` feature, this caused a problem when called and then later modified to a different amount
In KIP-17, there is no allowance because every NFT is unique, the quantity is none or one.
Therefore, we receive the benefits of KIP-7's original design without problems that have been later discovered.

Creating of NFTs ("minting") and destruction NFTs ("burning") is not included in the specification.
Your contract may implement these by other means.
Please see the `event` documentation for your responsibilities when creating or destroying NFTs.

We questioned if the `operator` parameter on `onKIP17Received` was necessary.
In all cases we could imagine, if the operator was important, the operator could transfer the token to themselves and then send it -- then they would be the `from` address.
This seems contrived because we consider the operator to be a temporary owner of the token (and transferring to themselves is redundant).
When the operator sends the token, it is the operator acting on their own accord, NOT the operator acting on behalf of the token holder.
This is why the operator and the previous token owner are both significant to the token recipient.

*Alternatives considered: only allow two-step KIP-7 style transaction, require that transfer functions never throw, require all functions to return a boolean indicating the success of the operation.*

**KIP-13 Interface**

We chose Interface Query Standard (KIP-13) to expose the interfaces that a KIP-17 smart contract supports.

A future KIP may create a global registry of interfaces for contracts.
We strongly support such an KIP and it would allow your KIP-17 implementation to implement `KIP17Enumerable`, `KIP17Metadata`, or other interfaces by delegating to a separate contract.

**Gas and Complexity** (regarding the enumeration extension)

This specification contemplates implementations that manage a few and *arbitrarily large* numbers of NFTs. If your application is able to grow then avoid using for/while loops in your code. These indicate your contract may be unable to scale and gas costs will rise over time without bound.

We have deployed a KIP-17 contract to Testnet which instantiates and tracks 340282366920938463463374607431768211456 different deeds (2^128).
That's enough to assign every IPV6 address to a Klaytn account owner, or to track ownership of nanobots a few micron in size and in aggregate totalling half the size of Earth.
You can query it from the blockchain.

This illustration makes clear: the KIP-17 standard scales.

*Alternatives considered: remove the asset enumeration function if it requires a for-loop, return a Solidity array type from enumeration functions.*

**Privacy**

Wallets/brokers/auctioneers identified in the motivation section have a strong need to identify which NFTs an owner owns.

It may be interesting to consider a use case where NFTs are not enumerable, such as a private registry of property ownership, or a partially-private registry.
However, privacy cannot be attained because an attacker can simply (!) call `ownerOf` for every possible `tokenId`.

**Metadata Choices** (metadata extension)

We have required `name` and `symbol` functions in the metadata extension.

We remind implementation authors that the empty string is a valid response to `name` and `symbol` if you protest to the usage of this mechanism.
We also remind everyone that any smart contract can use the same name and symbol as *your* contract.
How a client may determine which KIP-17 smart contracts are well-known (canonical) is outside the scope of this standard.

A mechanism is provided to associate NFTs with URIs.
We expect that many implementations will take advantage of this to provide metadata for each NFT.
The image size recommendation is taken from Instagram, they probably know much about image usability.
The URI MAY be mutable (i.e. it changes from time to time).
We considered an NFT representing ownership of a house, in this case metadata about the house (image, occupants, etc.) can naturally change.

Metadata is returned as a string value. Currently this is only usable as calling from SDKs (e.g., caver), not from other contracts. This is acceptable because we have not considered a use case where an on-blockchain application would query such information.

*Alternatives considered: put all metadata for each asset on the blockchain (too expensive), use URL templates to query metadata parts (URL templates do not work with all URL schemes, especially P2P URLs), multiaddr network address (not mature enough)*

## Backwards Compatibility
Not available.

## Test Cases
N/A

## Implementation
This section will be added later if implementation of this proposal appears.

## References
- [https://eips.ethereum.org/EIPS/eip-721](https://eips.ethereum.org/EIPS/eip-721)
- [https://klaytn.github.io/kips/KIPs/kip-7-fungible_token](https://klaytn.github.io/kips/KIPs/kip-7-fungible_token)
- [https://klaytn.github.io/kips/KIPs/kip-interface_query_standard](https://klaytn.github.io/kips/KIPs/kip-interface_query_standard)

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
