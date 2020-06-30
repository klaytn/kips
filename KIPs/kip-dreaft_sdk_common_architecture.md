---
kip: <to be assigned>
title: Klaytn SDK Common Architecture
author: Junghyun Colin Kim <colin.kim@groundx.xyz>, Jimin Kim <jasmine.kim@groundx.xyz>, Seonyong Kim <kale.kim@groundx.xyz>
discussions-to: <URL>
status: Draft
type: <Standards Track | Meta | Informational>
category (*only required for Standard Track): <Core | Networking | Storage | Interface | KCT | SDK | Application>
created: <date created on, in ISO 8601 (yyyy-mm-dd) format>
requires (*optional): <KIP number(s)>
replaces (*optional): <KIP number(s)>
---

## Simple Summary
A new software architecture for Klaytn development environment which is shared by all Klaytn SDKs.

## Abstract
The following standard allows Klaytn's SDK, Caver, to implement a common architecture regardless of language.

## Motivation
The terms used in the Klaytn SDK are different, and there is no structure to implement when the SDK is developed with other languages.

The common architecture is designed to unify the terms used in the SDK and easily extend to other languages by establishing a language independent common architecture.

## Specification

### Terminology

|Term|Description|
|---|---|
| [Account](#account-layer-class-diagram) | Represents a structure that contains informations needed to update the [AccountKey] of the account in the Klaytn blockchain platform (Klaytn). |
| [Keyring](#wallet-layer-class-diagram) | Represents a structure that contains the address of the account and the private key(s). This is a class that allows users to sign on using their own [Klaytn's account] through the Caver. |
| [Wallet](#wallet-layer-class-diagram) | Represents an in-memory wallet that can manage multiple keyring instances. |
| [Transaction](#transaction-layer-class-diagram) | Represents transactions based on Klaytn's various transaction types. |
| [RPC](#transaction-layer-class-diagram) | Represents a json-rpc call that interacts with a Klaytn Node. |
| [Contract](#contract-abi-kct-layer-class-diagram) | Represents a smart contract object that interacts with smart contracts on the Klaytn. |
| [ABI](#contract-abi-kct-layer-class-diagram) | Represents a decode and encode parameter module with an ABI (Application Binary Interface). |
| [KCT](#contract-abi-kct-layer-class-diagram) | Represents a smart contract object that interacts with KCT token contracts on the Klaytn. |
| [Utils](#utils-layer-class-diagram) | Represents the utility functions. |


### Layer Diagram

Diagram showing the layers of the SDK. Components belonging to each layer are represented inside the box that represents each layer.

![layerDiagram](https://user-images.githubusercontent.com/32922423/85986440-355d0180-ba27-11ea-8475-afe7638e6ffb.png)

The `KCT` layer allows you to interact with KCT token contracts (e.g. [KIP-7] or [KIP-17]). This is implemented by extending the `Contract` class belonging to the Contract layer.

The `Contract` layer allows you to interact with smart contracts on the Klaytn.

The `ABI` layer provides the functions to encode and decode parameters based on ABI.

Classes exist for each transaction type in the `Transaction` layer, and include the `TransactionDecoder` class that decodes the RLP-encoded transaction string, and the `TransactionHasher` class that calculates the hash of the transaction.

The `Wallet` layer contains Keyring (`SingleKeyring`, `MultipleKeyring`, and `RoleBasedKeyring`) classes and `KeyringContainer` class that acts as an "in-memory wallet" that stores the actual Keyring instances.

The `Account` layer contains an Account class that stores information needed when updating the [AccountKey] of the account in the Klaytn.

Also, the `RPC` layer includes the `Klay` class, which is responsible for rpc calls in the klay namespace, and the `Net` class, which is responsible for rpc calls in the net namespace.

Finally, in the `Utils` layer there is a Utils class that provides utility functions.

### Overall Class Diagram

This is the overall class diagram of the SDK. From the next chapter, it is divided into detailed groups focusing on the functions provided.

<!-- Please put Diagram here. -->

### Account Layer Class Diagram

The `Account` layer provides functionality related to updating the [AccountKey] of the Klatyn account.

![account](https://user-images.githubusercontent.com/32922423/86084568-2da96580-bad8-11ea-9c46-e74ae6d8ad7a.png)

`Account` is a class that contains informations needed to update the [AccountKey] of the account in the Klaytn. Inside, it has `address` and `accountKey` as member variables. The `accountKey` can be an instance of AccountKey (`AccountKeyLegacy`, `AccountKeyPublic`, `AccountKeyFail`, `AccountKeyWeightedMultiSig` or `AccountKeyRoleBased`) depending on the key. 

Account is used in the `account` field of the AccountUpdate transaction (`AccountUpdate`, `FeeDelegatedAccountUpdate` or `FeeDelegatedAccountUpdateWithRatio`). When the AccountUpdate transaction is successfully processed in Klaytn, the [AccountKey] of the [Klaytn account] is updated with the `accountKey` defined in Account.

Interface for AccountKey is defined as `IAccountKey`, and each AccountKey (`AccountKeyLegacy`, `AccountKeyPublic`, `AccountKeyFail`, `AccountKeyWeightedMultiSig` and `AccountKeyRoleBased`) implements IAccountKey.

`WeightedMultiSigOptions` for AccountKeyWeightedMultiSig where threshold and weight of each key are defined are also provided as classes.

The `AccountKeyDecoder` class decodes the RLP-encoded string using the decode function implemented in each AccountKey class.

### Wallet Layer Class Diagram

The `Wallet` layer allows the user to sign a message or a transaction through the Caver with a [Klaytn account].

![wallet](https://user-images.githubusercontent.com/32922423/86085859-3485a780-badb-11ea-966c-8812ecf5b29d.png)

In the Wallet layer, an abstract class called `AbstractKeyring` is defined, and `SingleKeyring`, `MultipleKeyring` and `RoleBasedKeyring` are implemented by extending AbstractKeyring. AbstractKeyring defines abstract methods that Keyring classes must implement.

`SingleKeyring` is a Keyring class that uses "only one private key", and `MultipleKeyring` is a Keyring class that uses "multiple private keys". `RoleBasedKeyring` is a Keyring class that uses "different private key(s) for each role", and the `keys` member variable is a 2D array in which keys to be used for each role are defined inside the array. 

Each Keyring class uses the `PrivateKey` class, which has one private key as a member variable.

`KeyringFactory` provides static methods for creating `SingleKeyring`, `MultipleKeyring` or `RoleBasedKeyring`.

`MessageSigned` is a structure that contains the result of signing a message and is used as a result of the `signMessage` function.

`SignatureData` is a structure that stores a signature.

`Keystore` is a class that contains encrypted keyring. The internally defined value differs depending on the keystore version, see [KIP-3](./kip-3.md).

`KeyringContainer` is an "in-memory wallet" class that manages Keyring instances. Manage the Keyring instance using the address as the key value.

### Transaction Layer Class Diagram

The `Transaction` layer provides transaction-related functions.

![transaction](https://user-images.githubusercontent.com/32922423/86089287-ebd1ec80-bae2-11ea-9061-09177d4f22e9.png)

`AbstractTransaction`, `AbstractFeeDelegatedTransaction` and `AbstractFeeDelegatedWithRatioTrasnaction` abstract classes are defined in the Transaction layer. 

`AbstractTransaction` defines variables and methods commonly used in all transactions. In addition, abstract methods that must be implemented in classes that extend AbstractTransaction are also defined. `AbstractFeeDelegatedTransaction` extends AbstractTransaction, and AbstractFeeDelegatedTransaction defines variables and methods commonly used in Fee Delegation and Partial Fee Delegation transactions. `AbstractFeeDelegatedWithRatioTransaction` extends AbstractFeeDelegatedTransaction, and AbstractFeeDelegatedWithRatioTransaction defines variables commonly used in Partial Fee Delegation transactions.

Among the transaction types used in the Klatyn, [Basic transactions] are implemented by extending `AbstractTransaction`. [Fee Delegation transactions] are implemented by extending `AbstractFeeDelegatedTransaction`, [Partial Fee Delegation transactions] are implemented by extending `AbstractFeeDelegatedWithRatioTransaction`.

The `TransactionDecoder` class decodes the RLP-encoded string using the decode function implemented in each Transaction class.

`TransactionHasher` is a class that calculates the hash of a transaction. It provides a function that calculates a hash when the sender (from of the transaction) signs a transaction and a function that calculates a hash when the fee payer signs a transaction. TransactionHasher provided by caver is implemented based on [Klaytn Design - Transactions].

### RPC Layer Class Diagram

The `RPC` layer provides the functions to use the Node API. The `RPC` is a class that manages the Node API for each namespace. Node APIs currently provided by Caver are [klay] and [net].

<!-- Please put Diagram here. -->

`Klay` is a class that provides [Node API of klay namespace]. `Net` is a class that provides [Node API of net namespace]. The result value received from Klaytn Node is returned to the user. For more information about each API and the returned result, refer to [JSON-RPC APIs].

### Contract, ABI, KCT Layer Class Diagram

The `Contract` layer provides the functions to interact with smart contracts on Klaytn. This Contract layer uses the function of the `ABI` layer that provides the functions to encode and decode parameters with the ABI (Application Binary Interface). `KCT` is a layer that provides the functions to interact with KCT token contracts (i.e [KIP-7] or [KIP-17]) on Klaytn.

<!-- Please put Diagram here. -->

The `Contract` class makes it easy to interact with smart contracts based on ABI. Also, if you pass byte code and constructor parameters while calling the deploy method, you can use the Contract instance to deploy the smart contract to Klaytn. The Contract class processes the ABI so that the user can easily call the smart contract function through a member variable called `methods`.

The `ABI` class provides functions to encode and decode parameters using the ABI. The `Contract` class encodes and decodes the parameters required for smart contract deployment and execution using the functions provided by the ABI. If the user wants to create a transaction to deploy or execute a smart contract, he can create `input` using functions provided by the ABI.

The `KIP7` class provides the functions to interact with [KIP-7] token contracts on Klaytn. This class allows users to easily 
deploy and execute [KIP-7] token contracts on Klaytn. `KIP7` maps all functions defined in [KIP-7] and provides them as class methods.

The `KIP17` class provides the functions to interact with [KIP-17] token contracts on Klaytn. This class allows users to easily 
deploy and execute [KIP-17] token contracts on Klaytn. `KIP17` maps all functions defined in [KIP-17] and provides them as class methods.

### Utils Layer Class Diagram

The Utils layer provides utility functions.

![utils](https://user-images.githubusercontent.com/32922423/86078319-cf28bb00-bac8-11ea-93ce-39a9809b017e.png)

The Utils class provides basic utility functions required when using Caver, and also converting functions based on `KlayUnit`.

## Rationale
While designing the common architecture, I tried to use the concept used in Klaytn in the SDK as much as possible. In addition, in order to provide the functions of the existing Caver, it was designed not to break the existing structure.

## Backwards Compatibility
There is no compatibility problem. When the common architecture is implemented in the existing Klaytn SDK, Caver (caver-js, caver-java), the existing functions should be provided as it is.

## Test Cases
1. All of the functions defined in the above common architecture diagram should be provided.
2. The exsiting functions in caver-js and caver-java can be used.

## Implementation
PRs related to common architecture are linked to the issues below.

- caver-js
    - https://github.com/klaytn/caver-js/issues/249
- caver-java
	- https://github.com/klaytn/caver-java/issues/97

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).


[AccountKey]: https://docs.klaytn.com/klaytn/design/accounts#account-key
[Klaytn's account]: https://docs.klaytn.com/klaytn/design/accounts#klaytn-accounts
[Klaytn account]: https://docs.klaytn.com/klaytn/design/accounts#klaytn-accounts
[Basic transactions]: https://docs.klaytn.com/klaytn/design/transactions/basic
[Fee Delegation transactions]: https://docs.klaytn.com/klaytn/design/transactions/fee-delegation
[Partial Fee Delegation transactions]: https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation
[Klaytn Design - Transactions]: https://docs.klaytn.com/klaytn/design/transactions
[KIP-7]: ./kip-7.md
[KIP-17]: ./kip-17.md
[klay]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay
[Node API of klay namespace]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay
[net]: https://docs.klaytn.com/bapp/json-rpc/api-references/network
[Node API of net namespace]: https://docs.klaytn.com/bapp/json-rpc/api-references/network
[JSON-RPC APIs]: https://docs.klaytn.com/bapp/json-rpc/api-references