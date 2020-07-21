---
kip: 34
title: Klaytn SDK Common Architecture
author: Jimin Kim <jasmine.kim@groundx.xyz>, Seonyong Kim <kale.kim@groundx.xyz>, Junghyun Colin Kim <colin.kim@groundx.xyz>
discussions-to: https://github.com/klaytn/kips/issues/35
status: Draft
type: Standards Track
category: SDK
created: 2020-07-02
---

## Simple Summary
A new software architecture for Klaytn development environment which is shared by all Klaytn SDKs (also known as 'caver' series).

## Abstract
The following standard allows Klaytn's SDK, Caver, to implement a common architecture regardless of programming languages.

## Motivation
Klaytn SDKs (caver-js and caver-java) do not share common terminology and software architecture.
It makes difficult to implement blockchain applications using multiple programming languages.
For example, if the server program is implemented in Java and the client is implemented in Javascript,
the developer should learn two different SDKs that have different terminology and software architecture
even if those programs utilize a single blockchain platform, Klaytn.

The common architecture is designed to unify the terminology used in the SDKs and easily extend to other languages by establishing a language-independent common architecture.

With the common architecture, we want to achieve two goals:
- Developers can easily implement their application using another language if they have implemented in any Klaytn SDK before.
- An SDK in another programming language can be implemented relatively easily because the software architecture is commonly defined.

## Specification

### Terminology

|Term|Description|
|---|---|
| [Account](https://docs.klaytn.com/klaytn/design/accounts#overview-of-account-state-and-address) | A data structure containing information about a person's balance or a smart contract. Klaytn provides the function to separate the address of the account from the key pair used in the account, so the account stores the [AccountKey] used in the account. |
| Keyring | A data structure containing Klaytn's account address and private key(s). It is used to sign a transaction. |
| [Transaction](https://docs.klaytn.com/klaytn/design/transactions#transactions-overview) | A data structure sent between nodes that changes the state of the blockchain. Klaytn provides [multiple transaction types] that empower transactions with new capabilities and optimizations for memory footprint and performance. |
| [JSON-RPC](https://www.jsonrpc.org/specification) | A stateless, light-weight remote procedure call (RPC) protocol. It uses JSON as data format. |
| Contract | A computer program or a transaction protocol which is intended to automatically execute, control or document legally relevant events and actions according to the terms of a contract or an agreement. You can deploy smart contract or execute smart contract that have already been deployed to Klaytn through a transaction. |
| ABI | An application binary interface (ABI) to communicate between two binary program modules. |
| [KCT](http://kips.klaytn.com/token) | Klaytn Compatible Token (KCT) is a special type of smart contract that implements certain technical specifications. |


### Overview of the Common Architecture

This is the overview of the common architecture of Klaytn SDK.

![all](https://user-images.githubusercontent.com/32922423/86310531-4e4cf900-bc59-11ea-8a4e-09a34f7f543d.png)

### Layer Diagram of the Common Architecture

Below diagram shows the layers of the common architecture. Components belonging to each layer are represented inside the layer box.

![layerDiagram](https://user-images.githubusercontent.com/32922423/85986440-355d0180-ba27-11ea-8475-afe7638e6ffb.png)

The `KCT` layer allows you to interact with Klaytn compatible token (KCT) contracts (e.g. [KIP-7] or [KIP-17]). This is implemented by extending the `Contract` class in the `Contract` layer.

The `Contract` layer allows you to interact with smart contracts on the Klaytn.

The `ABI` layer provides the functions to encode and decode parameters based on ABI.

The `Transaction` layer contains classes of Klaytn transaction types, `TransactionDecoder`, and `TransactionHasher`.

The `TransactionDecoder` class decodes the RLP-encoded transaction string. The `TransactionHasher` class calculates the hash of the transaction.

The `Wallet` layer contains keyring classes (`SingleKeyring`, `MultipleKeyring`, and `RoleBasedKeyring`) and `KeyringContainer` class that contains multiple keyrings. The `KeyringContainer` class acts as an "in-memory wallet" that stores the keyring instances.

The `Account` layer contains an `Account` class that stores information needed when updating the [AccountKey] of the account in the Klaytn.

Also, the `RPC` layer includes the `Klay` class, which is responsible for rpc calls of the klay namespace, and the `Net` class, which is responsible for rpc calls of the net namespace.

Finally, the `Utils` layer contains the `Utils` class that provides utility functions.

From the next chapter, each layer group is described in detail.

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

![rpc](https://user-images.githubusercontent.com/32922423/86310487-2fe6fd80-bc59-11ea-949d-42767bfcd521.png)

`Klay` is a class that provides [Node API of klay namespace]. `Net` is a class that provides [Node API of net namespace]. The result value received from Klaytn Node is returned to the user. For more information about each API and the returned result, refer to [JSON-RPC APIs].

### Contract, ABI, KCT Layer Class Diagram

The `Contract` layer provides the functions to interact with smart contracts on Klaytn. This Contract layer uses the function of the `ABI` layer that provides the functions to encode and decode parameters with the ABI (Application Binary Interface). `KCT` is a layer that provides the functions to interact with KCT token contracts (i.e [KIP-7] or [KIP-17]) on Klaytn.

![contract](https://user-images.githubusercontent.com/32922423/86310482-2cec0d00-bc59-11ea-94a3-74327094883d.png)

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

### Example of the source code

In this chapter, the pseudocode for sending a transaction using the SDK that implements the common architecture is explained.

```
input: keystore.json, password, from, to, value, gas
output: receipt of value transfer transaction

// Read keystore json file and decrypt keystore
keystore <- readFile('./keystore.json')
keyring <- decryptKeystore(keystore, password)

// Add to in-memory wallet
addToTheWallet(keyring)

// Create value transfer transaction
vt <- createValueTransferTransaction(from, to, value, gas)

// Sign to the transaction
signed <- sign(from, vt)

// Send transaction to the Klaytn blockchain platform (Klaytn)
receipt <- sendRawTransaction(signed)
print receipt
```


## Rationale
While designing the common architecture, I tried to use the concept used in Klaytn in the SDK as much as possible. In addition, in order to provide the functions of the existing Caver, it was designed not to break the existing structure.

## Backwards Compatibility
There is no compatibility problem. When the common architecture is implemented in the existing Klaytn SDK, Caver (caver-js, caver-java), the existing functions should be provided as it is.

## Test Cases
1. All of the functions defined in the above common architecture diagram should be provided.
2. The exsiting functions in caver-js and caver-java can be used.

## Implementation
PRs related to common architecture are linked to the issues below. The common architecture is implemented in caver-js v1.5.0 and caver-java v1.5.0.

- caver-js
    - https://github.com/klaytn/caver-js/issues/249
- caver-java
	- https://github.com/klaytn/caver-java/issues/97

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).


[AccountKey]: https://docs.klaytn.com/klaytn/design/accounts#account-key
[Klaytn's account]: https://docs.klaytn.com/klaytn/design/accounts#klaytn-accounts
[Klaytn account]: https://docs.klaytn.com/klaytn/design/accounts#klaytn-accounts
[multiple transaction types]: https://docs.klaytn.com/klaytn/design/transactions#klaytn-transactions
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
