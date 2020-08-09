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

# Table of contents

- [Simple Summary](#simple-summary)
- [Abstract](#abstract)
- [Motivation](#motivation)
- [Specification](#specification)
  - [Terminology](#terminology)
  - [Overview of the Common Architecture](#overview-of-the-common-architecture)
  - [Layer Diagram of the Common Architecture](#layer-diagram-of-the-common-architecture)
  - [Account Layer Class Diagram](#account-layer-class-diagram)
  - [Wallet Layer Class Diagram](#wallet-layer-class-diagram)
  - [Transaction Layer Class Diagram](#transaction-layer-class-diagram)
  - [RPC Layer Class Diagram](#rpc-layer-class-diagram)
  - [Contract, ABI, KCT Layer Class Diagram](#contract-abi-kct-layer-class-diagram)
  - [Utils Layer Class Diagram](#utils-layer-class-diagram)
- [Example of the source code](#example-of-the-source-code)
- [Rationale](#rationale)
- [Backwards Compatibility](#backwards-compatibility)
- [Test Cases](#test-cases)
- [Implementation](#implementation)
- [Copyright](#copyright)

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

| Term        | Description |
| ----------- | ----------- |
| Account | A data structure containing information like balance, nonce, public key(s), etc. Note that the public key(s) of the account can be changed in Klaytn because the public key(s) and the account address are decoupled. Please refer to [klaytn account] for more detail.  |
| Account key | A data structure representing various Klaytn account key types. Please refer to [accountkey] for more detail. |
| Keyring | A data structure containing Klaytn's account address and private key(s). It is used to sign a transaction. |
| [Transaction](https://docs.klaytn.com/klaytn/design/transactions#transactions-overview) | A data structure sent between nodes that changes the state of the blockchain. Klaytn provides [multiple transaction types] that empower transactions with new capabilities and optimizations for memory footprint and performance. |
| [JSON-RPC](https://www.jsonrpc.org/specification) | A stateless, light-weight remote procedure call (RPC) protocol. It uses JSON as data format. |
| Contract | A computer program or a transaction protocol which is intended to automatically execute, control or document legally relevant events and actions according to the terms of a contract or an agreement. You can deploy a smart contract or execute a smart contract that has already been deployed to Klaytn through a transaction. |
| ABI | An application binary interface (ABI) to communicate between two binary program modules. |
| [KCT (Klaytn Compatible Token)](http://kips.klaytn.com/token) | A special type of smart contract that implements token specifications defined in [Klaytn Improvement Proposals](http://kips.klaytn.com/). |

### Overview of the Common Architecture

This is the overview of the common architecture of Klaytn SDK.

![0805All](https://user-images.githubusercontent.com/32922423/89377494-e6447380-d72c-11ea-84f1-1cdc9894d5fa.png)

### Layer Diagram of the Common Architecture

Below diagram shows the layers of the common architecture. Components belonging to each layer are represented inside the layer box.

![layerDiagram](https://user-images.githubusercontent.com/32922423/85986440-355d0180-ba27-11ea-8475-afe7638e6ffb.png)

The `KCT` layer allows you to interact with Klaytn compatible token (KCT) contracts (e.g. [KIP-7] or [KIP-17]). This is implemented by extending the `Contract` class in the `Contract` layer.

The `Contract` layer allows you to interact with smart contracts on the Klaytn.

The `ABI` layer provides the functions to encode and decode parameters based on ABI.

The `Transaction` layer contains classes of Klaytn transaction types, `TransactionDecoder`, and `TransactionHasher`.

The `TransactionDecoder` class decodes the RLP-encoded transaction string. The `TransactionHasher` class calculates the hash of the transaction.

The `Wallet` layer contains keyring classes (`SingleKeyring`, `MultipleKeyring`, and `RoleBasedKeyring`) and `KeyringContainer` class that contains multiple keyrings. The `KeyringContainer` class acts as an "in-memory wallet" that stores the Keyring instances.

The `Account` layer contains an `Account` class that stores information needed when updating the [AccountKey] of the account in the Klaytn.

Also, the `RPC` layer includes the `Klay` class, which is responsible for rpc calls of the klay namespace, and the `Net` class, which is responsible for rpc calls of the net namespace.

Finally, the `Utils` layer contains the `Utils` class that provides utility functions.

From the next chapter, each layer is described in detail.

### Account Layer Class Diagram

The `Account` layer provides functionality related to updating the [AccountKey] of the Klaytn account.

![finalAccount](https://user-images.githubusercontent.com/32922423/89011409-44e3a900-d34b-11ea-8dc8-bed423c4e17a.png)

`Account` is a class that contains information needed to update the [AccountKey] of the account in the Klaytn. It has `address` and `accountKey` as member variables. The `accountKey` can be an instance of (`AccountKeyLegacy`, `AccountKeyPublic`, `AccountKeyFail`, `AccountKeyWeightedMultiSig` or `AccountKeyRoleBased`) depending on the key.

An `Account` instance is injected into the `account` field of the AccountUpdate transaction types (`AccountUpdate`, `FeeDelegatedAccountUpdate` or `FeeDelegatedAccountUpdateWithRatio`). When an AccountUpdate transaction is successfully processed in Klaytn, the account key of the [Klaytn account] is updated with the `accountKey` defined in the `Account` instance.

Interface for AccountKey is defined as `IAccountKey`, and account key classes (`AccountKeyLegacy`, `AccountKeyPublic`, `AccountKeyFail`, `AccountKeyWeightedMultiSig` and `AccountKeyRoleBased`) implements IAccountKey.

`WeightedMultiSigOptions` is provided for `AccountKeyWeightedMultiSig` where the threshold and the weight of each key are defined.

The `AccountKeyDecoder` class decodes the RLP-encoded string using the decode function implemented in each AccountKey class.

#### IAccountKey

| Method | Description |
| ----------- | ----------- |
| getRLPEncoding(): String | Returns an RLP-encoded string of AccountKey. AccountKey* classes below inherit `IAccountKey`, and this function must be implemented. |

#### AccountKeyLegacy

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyLegacy | Decodes an RLP-encoded string of AccountKeyLegacy and returns an `AccountKeyLegacy` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyLegacy. |

#### AccountKeyPublic

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyPublic | Decodes an RLP-encoded string of AccountKeyPublic and returns an `AccountKeyPublic` instance. It throws an exception if the decoding is failed. |
| fromXYPoint(x: String, y: String): AccountKeyPublic | Creates an `AccountKeyPublic` instance from x and y points. It throws an exception if the x and y points are invalid. |
| fromPublicKey(publicKey: String): AccountKeyPublic | Creates an `AccountKeyPublic` instance from public key string. It throws an exception if the public key is invalid. |
| getXYPoint(): String[] | Returns the x and y points of the public key. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyPublic. |

#### AccountKeyFail


| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyFail | Decodes an RLP-encoded string of AccountKeyFail and returns an `AccountKeyFail` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyFail. |

#### AccountKeyWeightedMultiSig

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyWeightedMultiSig | Decodes an RLP-encoded string of AccountKeyWeightedMultiSig and returns an `AccountKeyWeightedMultiSig` instance. It throws an exception if the decoding is failed. |
| fromPublicKeysAndOptions(pubArray: String[], options: WeightedMultiSigOptions): AccountKeyWeightedMultiSig | Creates an `AccountKeyWeightedMultiSig` instance with public key strings in `pubArray` and the options defining the threshold and the weight of each key in `WeightedMultiSigOptions `. It throws an exception if the options or public keys for accountKeyWeightedMultiSig are invalid. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyWeightedMultiSig. |

#### AccountKeyRoleBased

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyRoleBased | Decodes an RLP-encoded string of AccountKeyRoleBased. It throws an exception if the decoding is failed. |
| fromRoledPublicKeysAndOptions(pubArray: List<String[]>, options: List<WeightedMultiSigOptions>): AccountKeyRoleBased | Creates an instance of AccountKeyRoleBased with public key strings for each role and the option that defines threshold and weight of each key. It throws an exception if the public key(s) for each role or options is invalid. |
| fromRoledPublicKeysAndOptions(pubArray: List<String[]>): AccountKeyRoleBased | Creates an instance of AccountKeyRoleBased with public key strings for each role. This function assumes that all the values of the threshold and weights are set to be one. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyRoleBased. |

#### AccountKeyDecoder

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): IAccountKey | Decodes an RLP-encoded string of any class that inherits `IAccountKey`. It throws an exception if the decoding is failed. |

#### Account

| Method | Description |
| ----------- | ----------- |
| create(address: String, publicKey: String): Account | Generates an Account instance with an address and a public key string. |
| create(address: String, pubKeys: String[]): Account | Generates an Account instance with an address and public key strings. A default option with a threshold of 1 and a weight of 1 for each key will be used. |
| create(address: String, pubKeys: String[], options: WeightedMultiSigOptions): Account | Generates an Account instance with an address and public key strings and options that defines threshold and weight of each key. |
| create(address: String, roleBasedPubKeys: List<String[]>): Account | Creates an Account instance with an array of public keys defined for each role. A default option with a threshold of 1 and a weight of 1 for each key will be used for each role. |
| create(address: String, roleBasedPubKeys: List<String[]>, options: List<WeightedMultiSigOptions>): Account | Creates an Account instance with an array of public keys defined for each role and an array of options defined for each role. |
| createFromRLPEncoding(address: String, rlpEncodedKey: String): Account | Creates an Account instance with an address and RLP-encoded string. It throws an exception if the RLP-encoded string is invalid. |
| createWithAccountKeyLegacy(address: String): Account | Creates an Account instance which has AccountKeyLegacy as an accountKey. It throws an exception if the address string is invalid. |
| createWithAccountKeyPublic(address: String, publicKey: String): Account | Creates an Account instance which has AccountKeyPublic as an accountKey. It throws an exception if the address string or public key string is invalid. |
| createWithAccountKeyFail(address: String): Account | Creates an Account instance which has AccountKeyFail as an accountKey. It throws an exception if the address string is invalid. |
| createWithAccountKeyWeightedMultiSig(address: String, publicKeys: String[]): Account | Creates an Account instance which has AccountKeyWeightedMultiSig as an accountKey. The options required for AccountKeyWeightedMultiSig use default values (threshold:1, weight of each key: 1). It throws an exception if the address string or public key strings are invalid. |
| createWithAccountKeyWeightedMultiSig(address: String, publicKeys: String[], options: WeightedMultiSigOptions): Account | Creates an Account instance which has AccountKeyWeightedMultiSig as an accountKey. It throws an exception if the address string, public key strings or options are invalid. |
| createWithAccountKeyRoleBased(address: String, roleBasedPubKeys: List<String[]>): Account | Creates an Account instance which has AccountKeyRoleBased as an accountKey. If multiple keys are used among the defined roles, options use the default value (threshold:1, weight of each key: 1). It throws an exception if the address string or public key strings are invalid. |
| createWithAccountKeyRoleBased(address: String, roleBasedPubKeys: List<String[]>, options: List<WeightedMultiSigOptions>): Account | Creates an Account instance which has AccountKeyRoleBased as an accountKey. It throws an exception if the address string, public key strings or options are invalid. |
| getRLPEncodingAccountKey(): String | Return RLP-encoded string of AccountKey in Account instance. |

### Wallet Layer Class Diagram

The `Wallet` layer allows the user to sign a message or a transaction through the Caver with a [Klaytn account].

![finalWallet](https://user-images.githubusercontent.com/32922423/89011391-3eedc800-d34b-11ea-999e-da5a059ca2bf.png)

In the Wallet layer, an abstract class called `AbstractKeyring` is defined, and `SingleKeyring`, `MultipleKeyring` and `RoleBasedKeyring` are implemented by extending AbstractKeyring. AbstractKeyring defines abstract methods that Keyring classes must implement.

`SingleKeyring` is a Keyring class that uses "only one private key", and `MultipleKeyring` is a Keyring class that uses "multiple private keys". `RoleBasedKeyring` is a Keyring class that uses "different private key(s) for each role", and the `keys` member variable is a 2D array in which keys to be used for each role are defined inside the array.

Each Keyring class uses the `PrivateKey` class, which has one private key as a member variable.

`KeyringFactory` provides static methods for creating `SingleKeyring`, `MultipleKeyring` or `RoleBasedKeyring`.

`MessageSigned` is a structure that contains the result of signing a message and is used as a result of the `signMessage` function.

`SignatureData` is a structure that stores a signature.

`Keystore` is a class that contains encrypted keyring. The internally defined value differs depending on the keystore version, see [KIP-3](./kip-3.md).

`KeyringContainer` is an "in-memory wallet" class that manages Keyring instances. Manage the Keyring instance using the address as the key value.

#### PrivateKey

| Method | Description |
| ----------- | ----------- |
| sign(txHash: String, chainId: String): SignatureData | Signs the transaction. |
| sign(txHash: String, chainId: int): SignatureData | Signs the transaction. |
| signMessage(messageHash: String): SignatureData | Signs the message. |
| getPublicKey(compressed: Boolean): String | Returns public key string. |
| getDerivedAddress(): String | Returns derived address from private key string. |

#### AbstractKeyring

| Method | Description |
| ----------- | ----------- |
| sign(txHash: String, chainId: int, role: int): List&#60;SignatureData&#62; | Signs the transaction using key(s) defined in role. |
| sign(txHash: String, chainId: String, role: int): List&#60;SignatureData&#62; | Signs the transaction using key(s) defined in role. |
| sign(txHash: String, chainId: int, role: int, index: int): SignatureData | Signs the transaction using a key defined in role. |
| sign(txHash: String, chainId: String, role: int, index: int): SignatureData | Signs the transaction using a key defined in role. |
| signMessage(message: String, role: int): MessageSigned | Signs the message using key(s) defined in role. |
| signMessage(message: String, role: int, index: int): MessageSigned | Signs the message using a key defined in role. |
| getKlaytnWalletKey(): String | Returns KlaytnWalletKey string. |
| encrypt(password: String): Object | Encrypts a Keyring instance with keystore v4 format. |
| encrypt(password: String, options: Object): Object | Encrypts a Keyring instance with keystore v4 format. |
| encryptV3(password: String): Object | Encrypts a Keyring instance with keystore v3 format. |
| encryptV3(password: String, options: Object): Object | Encrypts a Keyring instance with keystore v3 format. |
| isDecoupled(): Boolean | Returns true if keyring has decoupled key. |
| copy(): AbstractKeyring | Returns a copied Keyring instance. |

#### SingleKeyrings

| Method | Description |
| ----------- | ----------- |
| getPublicKey(): String | Returns public key string. |
| getKeyByRole(role): PrivateKey | Returns keys by role. SingleKeyring always returns a same key. |
| toAccount(): Account | Returns an instance of Account. |

#### MultipleKeyring

| Method | Description |
| ----------- | ----------- |
| getPublicKey(): List&#60;String&#62; | Returns public key strings. |
| getKeyByRole(role): List&#60;PrivateKey&#62; | Returns keys by role. SingleKeyring always returns same keys. |
| toAccount(): Account | Returns an instance of Account. A default option with a threshold of 1 and a weight of 1 for each key will be used. |
| toAccount(options: WeightedMultiSigOptions): Account | Returns an instance of Account. It throws an exception if the options is invalid. |

#### RoleBasedKeyring

| Method | Description |
| ----------- | ----------- |
| getPublicKey(): List&#60;List&#60;String&#62;&#62; | Returns public key strings by roles. |
| getKeyByRole(role): List&#60;PrivateKey&#62; | Returns keys by role. |
| toAccount(): Account | Returns an instance of Account. A default option with a threshold of 1 and a weight of 1 for each key will be used for each role. |
| toAccount(options: List&#60;WeightedMultiSigOptions&#62;): Account | Returns an instance of Account. It throws an exception if the options is invalid. |

#### KeyringFactory

| Method | Description |
| ----------- | ----------- |
| generate(): SingleKeyring | Generates a SingleKeyring instance with a randomly generated private key. |
| generate(entropy: String): SingleKeyring | Generates a SingleKeyring instance with a randomly generated private key. |
| generateSingleKey(): String | Generates a private key string. |
| generateSingleKey(entropy: String): String | Generates a private key string. |
| generateMultipleKey(num: int): List&#60;String&#62; | Generates private key strings. |
| generateMultipleKey(num: int, entropy: String): List&#60;String&#62; | Generates private key strings. |
| generateRoleBasedKey(numArr: List&#60;int&#62;): List&#60;List&#60;String&#62;&#62; | Generates a 2D array of which each array element contains keys defined for each role. |
| generateRoleBasedKey(numArr: List&#60;int&#62;, entropy: String): List&#60;List&#60;String&#62;&#62; | Generates a 2D array of which each array element contains keys defined for each role. |
| create(address: String, key: String): SingleKeyring | Creates a SingleKeyring instance with an address and a private key string. It throws an exception if the address string or private key string is invalid. |
| create(address: String, keys: String[]): MultipleKeyring | Creates a MultipleKeyring instance with an address and private key strings. It throws an exception if the address string or private key strings are invalid. |
| create(address: String, roleBasedKeys: List&#60;String[]&#62;): RoleBasedKeyring | Creates a RoleBasedKeyring instance with an address and private key strings by roles. It throws an exception if the address string or private key strings are invalid. |
| createFromPrivateKey(key: String): SingleKeyring | Creates a SingleKeyring instance from a private key string or a KlaytnWalletKey. It throws an exception if the private key string is invalid. |
| createFromKlaytnWalletKey(klaytnWalletKey: String): SingleKeyring | Creates a SingleKeyring instance from a KlaytnWalletKey string. It throws an exception if the KlaytnWalletKey is invalid. |
| createWithSingleKey(address: String, key: String): SingleKeyring | Creates a SingleKeyring instance from an address and a private key string. It throws an exception if the address string or private key string is invalid. |
| createWithMultipleKey(address: String, keys: String[]): MultipleKeyring | Creates a MultipleKeyring instance from an address and private key strings. It throws an exception if the address string or private key strings are invalid. |
| createWithRoleBasedKey(address: String, roleBasedKeys: List&#60;String[]&#62;): RoleBasedKeyring | Creates a RoleBasedKeyring instance from an address and a 2D array of which each array element contains keys defined for each role. It throws an exception if the address string or private key strings are invalid. |
| decrypt(keystore: Object, password: String): Keyring | Decrypts a keystore v3 or v4 JSON and returns the decrypted Keyring instance. It throws an exception if the decrypting is failed. |

#### KeyringContainer

| Method | Description |
| ----------- | ----------- |
| generate(num: int, entropy: String): List&#60;String&#62; | Generates instances of SingleKeyring in the keyringContainer with randomly generated private keys. |
| add(keyring: AbstractKeyring): AbstractKeyring | Adds an instance of keyring to the keyringContainer. It throws an exception if the newly given keyring has the same address with one of the keyrings that already exist in `caver.wallet`. |
| newKeyring(address: String, privateKeyString: String): AbstractKeyring | Creates a keyring instance with given parameters and adds it to the `caver.wallet`. If key is a private key string, a SingleKeyring instance that uses a single private key is created. The keyring created is added to `caver.wallet`. It throws an exception if the address string or private key string is invalid. |
| newKeyring(address: String, privateKeyArray: List&#60;String&#62;): AbstractKeyring | Creates a keyring instance with given parameters and adds it to the `caver.wallet`. If key is an array containing private key strings, a MultipleKeyring instance that use multiple private keys is created. The keyring created is added to `caver.wallet`. It throws an exception if the address string or private key strings are invalid. |
| newKeyring(address: String, roleBasedPrivateKeyArray: List&#60;List&#60;String&#62;&#62;): AbstractKeyring | Creates a keyring instance with given parameters and adds it to the `caver.wallet`. If key is a 2D array of which each element contains the private key(s) to be used for each role, a RoleBasedKeyring instance is created. The keyring created is added to `caver.wallet`. It throws an exception if the address string or private key strings are invalid. |
| updateKeyring(keyring: AbstractKeyring): AbstractKeyring | Updates the keyring inside the keyringContainer. It throws an exception if the matching keyring is not found. |
| getKeyring(address: String): AbstractKeyring | Returns the keyring instance corresponding to the address. |
| sign(address: String, transaction: AbstractTransaction): AbstractTransaction | Signs the transaction as a sender of the transaction and appends signatures in the transaction object using the keyring in keyringContainer. This method will use all the private keys. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| sign(address: String, transaction: AbstractTransaction, index: int): AbstractTransaction | Signs the transaction as a sender of the transaction and appends a signature in the transaction object using the keyring in keyringContainer. This method uses the private key at the index th in the keyring. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| sign(address: String, transaction: AbstractTransaction, hasher: Function): AbstractTransaction | Signs the transaction as a sender of the transaction and appends signatures in the transaction object using the keyring in keyringContainer. This method will use all the private keys. When obtaining the transaction hash, the function transmitted by the user as a parameter is used. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| sign(address: String, transaction: AbstractTransaction, index: int, hasher: Function): AbstractTransaction | Signs the transaction as a sender of the transaction and appends a signature in the transaction object using the keyring in keyringContainer. This method uses the private key at the index th in the keyring. When obtaining the transaction hash, the function transmitted by the user as a parameter is used. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| signAsFeePayer(address: String, transaction: AbstractTransaction): AbstractTransaction | Signs the transaction as a fee payer of the transaction and appends signatures in the transaction object using the keyring in keyringContainer. This method will use all the private keys. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| signAsFeePayer(address: String, transaction: AbstractTransaction, index: int): AbstractTransaction | Signs the transaction as a fee payer of the transaction and appends a signature in the transaction object using the keyring in keyringContainer. This method uses the private key at the index th in the keyring. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| signAsFeePayer(address: String, transaction: AbstractTransaction, hasher: Function): AbstractTransaction | Signs the transaction as a fee payer of the transaction and appends signatures in the transaction object using the keyring in keyringContainer. This method will use all the private keys. When obtaining the transaction hash, the function transmitted by the user as a parameter is used. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| signAsFeePayer(address: String, transaction: AbstractTransaction, index: int, hasher: Function): AbstractTransaction | Signs the transaction as a fee payer of the transaction and appends a signature in the transaction object using the keyring in keyringContainer. This method uses the private key at the index th in the keyring. When obtaining the transaction hash, the function transmitted by the user as a parameter is used. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| signMessage(address: String, data: String, role: int): MessageSigned | Signs the message with Klaytn-specific prefix using the keyring stored in keyringContainer. This method will use all the private keys. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| signMessage(address: String, data: String, role: int, index: int): MessageSigned | Signs the message with Klaytn-specific prefix using the keyring stored in keyringContainer. This method uses the private key at the index th in the keyring. It throws an exception if the keyring to be used for signing cannot be found in `caver.wallet`. |
| remove(address: String): Boolean | Deletes the keyring from keyringContainer whose address matches the address of the given keyring. |

### Transaction Layer Class Diagram

The `Transaction` layer provides transaction-related functions.

![finalTransaction](https://user-images.githubusercontent.com/32922423/89011399-4319e580-d34b-11ea-8021-4b9358b98bcb.png)

`AbstractTransaction`, `AbstractFeeDelegatedTransaction` and `AbstractFeeDelegatedWithRatioTrasnaction` abstract classes are defined in the Transaction layer.

`AbstractTransaction` defines variables and methods commonly used in all transactions. In addition, abstract methods that must be implemented in classes that extend AbstractTransaction are also defined. `AbstractFeeDelegatedTransaction` extends AbstractTransaction, and AbstractFeeDelegatedTransaction defines variables and methods commonly used in Fee Delegation and Partial Fee Delegation transactions. `AbstractFeeDelegatedWithRatioTransaction` extends AbstractFeeDelegatedTransaction, and AbstractFeeDelegatedWithRatioTransaction defines variables commonly used in Partial Fee Delegation transactions.

Among the transaction types used in the Klatyn, [Basic transactions] are implemented by extending `AbstractTransaction`. [Fee Delegation transactions] are implemented by extending `AbstractFeeDelegatedTransaction`, [Partial Fee Delegation transactions] are implemented by extending `AbstractFeeDelegatedWithRatioTransaction`.

The `TransactionDecoder` class decodes the RLP-encoded string using the decode function implemented in each Transaction class.

`TransactionHasher` is a class that calculates the hash of a transaction. It provides a function that calculates a hash when the sender (from of the transaction) signs a transaction and a function that calculates a hash when the fee payer signs a transaction. TransactionHasher provided by caver is implemented based on [Klaytn Design - Transactions].

#### AbstractTransaction

| Method | Description |
| ----------- | ----------- |
| sign(keyString: String): AbstractTransaction | Signs the transaction as a transaction sender with the private key (or KlaytnWalletKey) and appends signatures in the transaction object. |
| sign(keyString: String, hasher: Function): AbstractTransaction | Signs the transaction as a transaction sender with the private key (or KlaytnWalletKey) and appends signatures in the transaction object. The hasher function will be used when get the hash of transaction. |
| sign(keyring: AbstractKeyring): AbstractTransaction | Signs the transaction as a transaction sender with the private keys in the keyring and appends signatures in the transaction object. |
| sign(keyring: AbstractKeyring, index: int): AbstractTransaction | Signs the transaction as a transaction sender with the a private key in the keyring and appends signatures in the transaction object. |
| sign(keyring: AbstractKeyring, hasher: Function): AbstractTransaction | Signs the transaction as a transaction sender with the private keys in the keyring and appends signatures in the transaction object. |
| sign(keyring: AbstractKeyring, index: int, hasher: Function): AbstractTransaction | Signs the transaction as a transaction sender with the a private key in the keyring and appends signatures in the transaction object. The hasher function will be used when get the hash of transaction. |
| appendSignatures(sig: SignatureData): void | Appends signature to the transaction. |
| appendSignatures(sig: List&#60;SignatureData&#62;): void | Appends signatures to the transaction. |
| combineSignedRawTransactions(rlpEncoded: List&#60;String&#62;): String | Collects signs in each RLP-encoded transaction string in the given array, combines them with the transaction instance, and returns an RLP-encoded transaction string which includes all signs. |
| getTransactionHash(): String | Returns a transactionHash. |
| getSenderTxHash(): String | Returns a senderTxHash of transaction. |
| getRawTransaction(): String | Returns a rawTransaction string (an RLP-encoded transaction string). This function is same with transaction.getRLPEncoding. |
| getRLPEncodingForSignature(): String | Returns an RLP-encoded transaction string for making the signature of the transaction sender. |
| fillTransaction(): void | Fills in the optional variables in transaction. |
| getRLPEncoding(): String | Returns an RLP-encoded transaction string. |
| getCommonRLPEncodingForSignautre(): String | Encodes and returns the values needed to sign each transaction. For example, in the case of ValueTransfer, if SigRLP is `encode([encode([type, nonce, gasPrice, gas, to, value, from]), chainid, 0, 0])`, among them, the RLP-encoded values of the transaction required for signing is `encoded([type, nonce, gasPrice, gas, to, value, from])`. This function is used in getRLPEncodingForSignature or getRLPEncodingForFeePayerSignature function. |

#### AbstractFeeDelegatedTransaction

| Method | Description |
| ----------- | ----------- |
| signAsFeePayer(keyString: String): AbstractFeeDelegatedTransaction | Signs the transaction as a transaction fee payer with a private key string (or KlaytnWalletKey) and appends feePayerSignatures in the transaction object with the private key(s) in the keyring. |
| signAsFeePayer(keyString: String, hasher: Function): AbstractFeeDelegatedTransaction | Signs the transaction as a transaction fee payer with a private key string (or KlaytnWalletKey) and appends feePayerSignatures in the transaction object with the private key(s) in the keyring. The hasher function will be used when get the hash of transaction. |
| signAsFeePayer(keyring: AbstractKeyring): AbstractFeeDelegatedTransaction | Signs the transaction as a transaction fee payer with private keys in the keyring and appends feePayerSignatures in the transaction object with the private key(s) in the keyring. |
| signAsFeePayer(keyring: AbstractKeyring, index: int): AbstractFeeDelegatedTransaction | Signs the transaction as a transaction fee payer with a private key in the keyring and appends feePayerSignatures in the transaction object with the private key(s) in the keyring. |
| signAsFeePayer(keyring: AbstractKeyring, hasher: Function): AbstractFeeDelegatedTransaction | Signs the transaction as a transaction fee payer with private keys in the keyring and appends feePayerSignatures in the transaction object with the private key(s) in the keyring. The hasher function will be used when get the hash of transaction. |
| signAsFeePayer(keyring: AbstractKeyring, index: int, hasher: Function): AbstractFeeDelegatedTransaction | Signs the transaction as a transaction fee payer with a private key in the keyring and appends feePayerSignatures in the transaction object with the private key(s) in the keyring. The hasher function will be used when get the hash of transaction. |
| appendFeePayerSignatures(sig: SignatureData): void | Appends feePayerSignatures to the transaction. |
| appendFeePayerSignatures(sig: List&#60;SignatureData&#62;): void | Appends feePayerSignatures to the tr  ansaction. |
| combineSignedRawTransactions(rlpEncoded: String): String | Collects signs in each RLP-encoded transaction string in the given array, combines them with the transaction instance, and returns an RLP-encoded transaction string which includes all signs. |
| getRLPEncodingForFeePayerSignature(): String | Returns an RLP-encoded transaction string for making the signature of the transaction fee payer. |

#### LegacyTransaction

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): LegacyTransaction | Decodes an RLP-encoded LegacyTransaction string, a raw transaction, and returns a LegacyTransaction instance. It throws an exception if the decoding is failed. |
| appendSignatures(sig: SignatureData): void | Appends signature to the transaction. LegacyTransaction can only have one signature. It throws an exception if multiple signatures are assigned to a `signatures`. |
| appendSignatures(sig: List&#60;SignatureData&#62;): void | Appends signature to the transaction. LegacyTransaction can only have one signature. It throws an exception if multiple signatures are assigned to a `signatures`. |
| getRLPEncoding(): String | Returns an RLP-encoded LegacyTransaction string. It throws an exception if the variables required for encoding are not defined. |
| getRLPEncodingForSignature(): String | Returns an RLP-encoded transaction string for making the signature of the transaction sender. Since the method of obtaining RLP-encoding for signature of LegacyTransaction is different from other transaction types, getRLPEncodingForSignature should be overrided. It throws an exception if the variables required for encoding are not defined. |

#### ValueTransfer

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): ValueTransfer | Decodes an RLP-encoded ValueTransfer string, a raw transaction, and returns a ValueTransfer instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded ValueTransfer string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### ValueTransferMemo

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): ValueTransferMemo | Decodes an RLP-encoded ValueTransferMemo string, a raw transaction, and returns a ValueTransferMemo instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded ValueTransferMemo string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### AccountUpdate

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): AccountUpdate | Decodes an RLP-encoded AccountUpdate string, a raw transaction, and returns a AccountUpdate instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded AccountUpdate string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### SmartContractDeploy

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): SmartContractDeploy | Decodes an RLP-encoded SmartContractDeploy string, a raw transaction, and returns a SmartContractDeploy instance. |
| getRLPEncoding(): String | Returns an RLP-encoded SmartContractDeploy string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### SmartContractExecution

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): SmartContractExecution | Decodes an RLP-encoded SmartContractExecution string, a raw transaction, and returns a SmartContractExecution instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded SmartContractExecution string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### Cancel

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): Cancel | Decodes an RLP-encoded Cancel string, a raw transaction, and returns a Cancel instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded Cancel string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### ChainDataAnchoring

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): ChainDataAnchoring | Decodes an RLP-encoded ChainDataAnchoring string, a raw transaction, and returns a ChainDataAnchoring instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded ChainDataAnchoring string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedValueTransfer

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedValueTransfer | Decodes an RLP-encoded FeeDelegatedValueTransfer string, a raw transaction, and returns a FeeDelegatedValueTransfer instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedValueTransfer string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedValueTransferMemo

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedValueTransferMemo | Decodes an RLP-encoded FeeDelegatedValueTransferMemo string, a raw transaction, and returns a FeeDelegatedValueTransfer instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): Stirng | Returns an RLP-encoded FeeDelegatedValueTransferMemo string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedAccountUpdate

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedAccountUpdate | Decodes an RLP-encoded FeeDelegatedAccountUpdate string, a raw transaction, and returns a FeeDelegatedAccountUpdate instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedAccountUpdate string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedSmartContractDeploy

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedSmartContractDeploy | Decodes an RLP-encoded FeeDelegatedSmartContractDeploy string, a raw transaction, and returns a FeeDelegatedSmartContractDeploy instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedSmartContractDeploy string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedSmartContractExecution

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedSmartContractExecution | Decodes an RLP-encoded FeeDelegatedSmartContractExecution string, a raw transaction, and returns a FeeDelegatedSmartContractExecution instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedSmartContractExecution string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedCancel

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedCancel | Decodes an RLP-encoded FeeDelegatedCancel string, a raw transaction, and returns a FeeDelegatedCancel instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedCancel string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedChainDataAnchoring

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedChainDataAnchoring | Decodes an RLP-encoded FeeDelegatedChainDataAnchoring string, a raw transaction, and returns a FeeDelegatedChainDataAnchoring instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedChainDataAnchoring string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedValueTransferWithRatio

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedValueTransferWithRatio | Decodes an RLP-encoded FeeDelegatedValueTransferWithRatio string, a raw transaction, and returns a FeeDelegatedValueTransferWithRatio instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedValueTransferWithRatio string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedValueTransferMemoWithRatio

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedValueTransferMemoWithRatio | Decodes an RLP-encoded FeeDelegatedValueTransferMemoWithRatio string, a raw transaction, and returns a FeeDelegatedValueTransferMemoWithRatio instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): Stirng | Returns an RLP-encoded FeeDelegatedValueTransferMemoWithRatio string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedAccountUpdateWithRatio

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedAccountUpdateWithRatio | Decodes an RLP-encoded FeeDelegatedAccountUpdateWithRatio string, a raw transaction, and returns a FeeDelegatedAccountUpdateWithRatio instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedAccountUpdateWithRatio string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedSmartContractDeployWithRatio

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedSmartContractDeployWithRatio | Decodes an RLP-encoded FeeDelegatedSmartContractDeployWithRatio string, a raw transaction, and returns a FeeDelegatedSmartContractDeployWithRatio instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedSmartContractDeployWithRatio string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedSmartContractExecutionWithRatio

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedSmartContractExecutionWithRatio | Decodes an RLP-encoded FeeDelegatedSmartContractExecutionWithRatio string, a raw transaction, and returns a FeeDelegatedSmartContractExecutionWithRatio instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedSmartContractExecutionWithRatio string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedCancelWithRatio

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedCancelWithRatio | Decodes an RLP-encoded FeeDelegatedCancelWithRatio string, a raw transaction, and returns a FeeDelegatedCancelWithRatio instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedCancelWithRatio string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedChainDataAnchoringWithRatio

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedChainDataAnchoringWithRatio | Decodes an RLP-encoded FeeDelegatedChainDataAnchoringWithRatio string, a raw transaction, and returns a FeeDelegatedChainDataAnchoringWithRatio instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded FeeDelegatedChainDataAnchoringWithRatio string. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. It throws an exception if the variables required for encoding are not defined. |

#### TransactionDecoder

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): AbstractTransaction | Decodes an RLP-encoded transaction string, a raw transaction, and returns a Transaction instance. It throws an exception if the decoding is failed. |

#### TransactionHasher

| Method | Description |
| ----------- | ----------- |
| getHashForSignature(transaction: AbstractTransaction): String | Returns the hash of the transaction for the sender to sign. |
| getHashForFeePayerSignature(transaction: AbstractFeeDelegatedTransaction): String | Returns the hash of the transaction for the fee payer to sign. |

### RPC Layer Class Diagram

The `RPC` layer provides the functions to use the Node API. The `RPC` is a class that manages the Node API for each namespace. Node APIs currently provided by Caver are [klay] and [net].

![0727RPC](https://user-images.githubusercontent.com/32922423/88506771-ac30ee80-d015-11ea-8d33-b4be4835bef6.png)

`Klay` is a class that provides [Node API of klay namespace]. `Net` is a class that provides [Node API of net namespace]. The result value received from Klaytn Node is returned to the user. For more information about each API and the returned result, refer to [JSON-RPC APIs].

#### Klay

| Method | Description |
| ----------- | ----------- |
| accountCreated(address: String): Boolean | Call `klay_accountCreated` JSON-RPC. |
| accountCreated(address: String, blockNumber: int): Boolean | Call `klay_accountCreated` JSON-RPC. |
| accountCreated(address: String, blockTag: String): Boolean | Call `klay_accountCreated` JSON-RPC. |
| getAccounts(): List&#60;String&#62; | Call `klay_accounts` JSON-RPC. |
| encodeAccountKey(accountKey: AccountKey): String | Call `klay_encodeAccountKey` JSON-RPC. |
| decodeAccountKey(encodedAccountKey: String): Object | Call `klay_decodeAccountKey` JSON-RPC. |
| getAccount(address: String): Object | Call `klay_getAccount` JSON-RPC. |
| getAccount(address: String, blockNumber: int): Object | Call `klay_getAccount` JSON-RPC. |
| getAccount(address: String, blockTag: String): Object | Call `klay_getAccount` JSON-RPC. |
| getAccountKey(address: String): Object | Call `klay_getAccountKey` JSON-RPC. |
| getAccountKey(address: String, blockNumber: int): Object | Call `klay_getAccountKey` JSON-RPC. |
| getAccountKey(address: String, blockTag: String): Object | Call `klay_getAccountKey` JSON-RPC. |
| getBalance(address: String): String | Call `klay_getBalance` JSON-RPC. |
| getBalance(address: String, blockNumber: int): String | Call `klay_getBalance` JSON-RPC. |
| getBalance(address: String, blockTag: String): String | Call `klay_getBalance` JSON-RPC. |
| getCode(address: String): String | Call `klay_getCode` JSON-RPC. |
| getCode(address: String, blockNumber: int): String | Call `klay_getCode` JSON-RPC. |
| getCode(address: String, blockTag: String): String | Call `klay_getCode` JSON-RPC. |
| getTransactionCount(address: String): String | Call `klay_getTransactionCount` JSON-RPC. |
| getTransactionCount(address: String, blockNumber: int): String | Call `klay_getTransactionCount` JSON-RPC. |
| getTransactionCount(address: String, blockTag: String): String | Call `klay_getTransactionCount` JSON-RPC. |
| isContractAddress(address: String): Boolean | Call `klay_isContractAccount` JSON-RPC. |
| isContractAddress(address: String, blockNumber: int): Boolean | Call `klay_isContractAccount` JSON-RPC. |
| isContractAddress(address: String, blockTag: String): Boolean | Call `klay_isContractAccount` JSON-RPC. |
| sign(address: String, message: String): String | Call `klay_sign` JSON-RPC. |
| getBlockNumber(): String | Call `klay_blockNumber` JSON-RPC. |
| getBlockByNumber(blockNumber: int): Object | Call `klay_getBlockByNumber` JSON-RPC. |
| getBlockByNumber(blockNumber: int, fullTxs: Boolean): Object | Call `klay_getBlockByNumber` JSON-RPC. |
| getBlockByNumber(blockTag: String): Object | Call `klay_getBlockByNumber` JSON-RPC. |
| getBlockByNumber(blockTag: String, fullTxs: Boolean): Object | Call `klay_getBlockByNumber` JSON-RPC. |
| getBlockByHash(blockHash: String): Object | Call `klay_getBlockByHash` JSON-RPC. |
| getBlockByHash(blockHash: String, fullTxs: Boolean): Object | Call `klay_getBlockByHash` JSON-RPC. |
| getBlockReceipts(blockHash: String): Object | Call `klay_getBlockReceipts` JSON-RPC. |
| getBlockTransactionCountByNumber(blockNumber: int): Object | Call `klay_getBlockTransactionCountByNumber` JSON-RPC. |
| getBlockTransactionCountByNumber(blockTag: String): Object | Call `klay_getBlockTransactionCountByNumber` JSON-RPC. |
| getBlockTransactionCountByHash(blockHash: String): Object | Call `klay_getBlockTransactionCountByHash` JSON-RPC. |
| getBlockWithConsensusInfoByHash(blockHash: String): Object | Call `klay_getBlockWithConsensusInfoByHash` JSON-RPC. |
| getBlockWithConsensusInfoByNumber(blockNumber: int): Object | Call `klay_getBlockWithConsensusInfoByNumber` JSON-RPC. |
| getBlockWithConsensusInfoByNumber(blockTag: String): Object | Call `klay_getBlockWithConsensusInfoByNumber` JSON-RPC. |
| getCommittee(): List&#60;String&#62; | Call `klay_getCommittee` JSON-RPC. |
| getCommittee(blockNumber: int): List&#60;String&#62; | Call `klay_getCommittee` JSON-RPC. |
| getCommittee(blockTag: String): List&#60;String&#62; | Call `klay_getCommittee` JSON-RPC. |
| getCommitteeSize(): int | Call `klay_getCommitteeSize` JSON-RPC. |
| getCommitteeSize(blockNumber: int): int | Call `klay_getCommitteeSize` JSON-RPC. |
| getCommitteeSize(blockTag: String): int | Call `klay_getCommitteeSize` JSON-RPC. |
| getCouncil(): List&#60;String&#62; | Call `klay_getCouncil` JSON-RPC. |
| getCouncil(blockNumber: int): List&#60;String&#62; | Call `klay_getCouncil` JSON-RPC. |
| getCouncil(blockTag: String): List&#60;String&#62; | Call `klay_getCouncil` JSON-RPC. |
| getCouncilSize(): int | Call `klay_getCouncilSize` JSON-RPC. |
| getCouncilSize(blockNumber: int): int | Call `klay_getCouncilSize` JSON-RPC. |
| getCouncilSize(blockTag: String): int | Call `klay_getCouncilSize` JSON-RPC. |
| getStorageAt(address: String, position: int, blockNumber: int): String | Call `klay_getStorageAt` JSON-RPC. |
| getStorageAt(address: String, position: int, blockTag: String): String | Call `klay_getStorageAt` JSON-RPC. |
| isSyncing(): Object | Call `klay_syncing` JSON-RPC. |
| call(callObject: Object): String | Call `klay_call` JSON-RPC. |
| call(callObject: Object, blockNumber: int): String | Call `klay_call` JSON-RPC. |
| call(callObject: Object, blockTag: String): String | Call `klay_call` JSON-RPC. |
| estimateGas(callObject: Object): String | Call `klay_estimateGas` JSON-RPC. |
| estimateGas(callObject: Object, blockNumber: int): String | Call `klay_estimateGas` JSON-RPC. |
| estimateGas(callObject: Object, blockTag: String): String | Call `klay_estimateGas` JSON-RPC. |
| estimateComputationCost(callObject: Object): String | Call `klay_estimateComputationCost` JSON-RPC. |
| estimateComputationCost(callObject: Object, blockNumber: int): String | Call `klay_estimateComputationCost` JSON-RPC. |
| estimateComputationCost(callObject: Object, blockTag: String): String | Call `klay_estimateComputationCost` JSON-RPC. |
| getTransactionByBlockHashAndIndex(hash: String, index: int): Object | Call `klay_getTransactionByBlockHashAndIndex` JSON-RPC. |
| getTransactionByBlockNumberAndIndex(blockNumber: int, index: int): Object | Call `klay_getTransactionByBlockHashAndIndex` JSON-RPC. |
| getTransactionByBlockNumberAndIndex(blockTag: String, index: int): Object | Call `klay_getTransactionByBlockHashAndIndex` JSON-RPC. |
| getTransactionByHash(hash: String): Object | Call `klay_getTransactionByHash` JSON-RPC. |
| getTransactionBySenderTxHash(senderTxHash: String): Object | Call `klay_getTransactionBySenderTxHash` JSON-RPC. |
| getTransactionReceipt(hash: String): Object | Call `klay_getTransactionReceipt` JSON-RPC. |
| getTransactionReceiptBySenderTxHash(senderTxHash: String): Object | Call `klay_getTransactionReceiptBySenderTxHash` JSON-RPC. |
| sendRawTransaction(rawTransaction: String): Object | Call `klay_sendRawTransaction` JSON-RPC. |
| sendTransaction(tx: AbstractTransaction): String | Call `klay_sendTransaction` JSON-RPC. |
| sendTransactionAsFeePayer(tx: AbstractFeeDelegatedTransaction): String | Call `klay_sendTransactionAsFeePayer` JSON-RPC. |
| signTransaction(tx: AbstractTransaction): Object | Call `klay_signTransaction` JSON-RPC. |
| signTransactionAsFeePayer(tx: AbstractFeeDelegatedTransaction): Object | Call `klay_signTransactionAsFeePayer` JSON-RPC. |
| getDecodedAnchoringTransaction(hash: String): Object | Call `klay_getDecodedAnchoringTransactionByHash` JSON-RPC. |
| getChainId(): String | Call `klay_chainID` JSON-RPC. |
| getClientVersion(): String | Call `klay_clientVersion` JSON-RPC. |
| getGasPrice(): String | Call `klay_gasPrice` JSON-RPC. |
| getGasPriceAt(): String | Call `klay_gasPriceAt` JSON-RPC. |
| getGasPriceAt(blockNumber: int): String | Call `klay_gasPriceAt` JSON-RPC. |
| isParallelDBWrite(): Boolean | Call `klay_isParallelDBWrite` JSON-RPC. |
| isSenderTxHashIndexingEnabled(): Boolean | Call `klay_isSenderTxHashIndexingEnabled` JSON-RPC. |
| getProtocolVersion(): String | Call `klay_protocolVersion` JSON-RPC. |
| getRewardbase(): String | Call `klay_rewardbase` JSON-RPC. |
| writeThroughCaching(): Boolean | Call `klay_writeThroughCaching` JSON-RPC. |
| getFilterChanges(filterId: String): List&#60;Object&#62; | Call `klay_getFilterChanges` JSON-RPC. |
| getFilterLogs(filterId: String): List&#60;Object&#62; | Call `klay_getFilterLogs` JSON-RPC. |
| getLogs(filterOption: Object): List&#60;Object&#62; | Call `klay_getLogs` JSON-RPC. |
| newBlockFilter(): String | Call `klay_newBlockFilter` JSON-RPC. |
| newFilter(filterOptions: Object): String | Call `klay_newFilter` JSON-RPC. |
| newPendingTransactionFilter(): String | Call `klay_newPendingTransactionFilter` JSON-RPC. |
| uninstallFilter(filterId: String): Boolean | Call `klay_uninstallFilter` JSON-RPC. |
| sha3(data: String): String | Call `klay_sha3` JSON-RPC. |

#### Net

| Method | Description |
| ----------- | ----------- |
| getNetworkID(): String | Call `net_networkID` JSON-RPC. |
| isListening(): Boolean | Call `net_listening` JSON-RPC. |
| getPeerCount(): String | Call `net_peerCount` JSON-RPC. |
| getPeerCountByType(): Object | Call `net_peerCountByType` JSON-RPC. |

### Contract, ABI, KCT Layer Class Diagram

The `Contract` layer provides the functions to interact with smart contracts on Klaytn. This Contract layer uses the function of the `ABI` layer that provides the functions to encode and decode parameters with the ABI (Application Binary Interface). `KCT` is a layer that provides the functions to interact with KCT token contracts (i.e [KIP-7] or [KIP-17]) on Klaytn.

![0805Contract](https://user-images.githubusercontent.com/32922423/89377502-ecd2eb00-d72c-11ea-84b2-d219bceb36d2.png)

The `Contract` class makes it easy to interact with smart contracts based on ABI. Also, if you pass byte code and constructor parameters while calling the deploy method, you can use the Contract instance to deploy the smart contract to Klaytn. The Contract class processes the ABI so that the user can easily call the smart contract function through a member variable called `methods`.

The `ABI` class provides functions to encode and decode parameters using the ABI. The `Contract` class encodes and decodes the parameters required for smart contract deployment and execution using the functions provided by the ABI. If the user wants to create a transaction to deploy or execute a smart contract, he can create `input` using functions provided by the ABI.

The `KIP7` class provides the functions to interact with [KIP-7] token contracts on Klaytn. This class allows users to easily
deploy and execute [KIP-7] token contracts on Klaytn. `KIP7` maps all functions defined in [KIP-7] and provides them as class methods.

The `KIP17` class provides the functions to interact with [KIP-17] token contracts on Klaytn. This class allows users to easily
deploy and execute [KIP-17] token contracts on Klaytn. `KIP17` maps all functions defined in [KIP-17] and provides them as class methods.

#### Contract

| Method | Description |
| ----------- | ----------- |
| deploy(deployParam: ContractDeployParams, options: SendOptions): Contract | Deploys the contract to the Klaytn. |
| once(event: String, callback: Function): void | Subscribes to an event and unsubscribes immediately after the first event or error. |
| once(event: String, options: Object, callback: Function): void | Subscribes to an event and unsubscribes immediately after the first event or error. The options object should define `filter` or `topics`. |
| getPastEvent(event: String): List&#60;Object&#62; | Gets past events for this contract. |
| getPastEvent(event: String, options: Object): List&#60;Object&#62; | Gets past events for this contract. The options object can define the filter options needed when calling [klay_logs]. See [klay_logs] for more details about options. |
| getPastEvent(event: String, callback: Function): List&#60;Object&#62; | Gets past events for this contract. |
| getPastEvent(event: String, options: Object, callback: Function): List&#60;Object&#62; | Gets past events for this contract. The options object can define the filter options needed when calling [klay_logs]. See [klay_logs] for more details about options. |

#### ContractMethod

| Method | Description |
| ----------- | ----------- |
| call(argumetns: List&#60;any&#62;, callObject: Object): any | Call a "constant" method and execute its smart contract method in the Klaytn Virtual Machine without sending any transaction. See [klay_call] for more details about callObject. |
| send(arguments: List&#60;any&#62;): Object | Send a transaction to the smart contract and execute its method. This can alter the smart contract state. Send a transaction using the value defined in defaultSendOptions of the Contract. It thorws an exception if the value required for transaction (i.e `from` or `gas`) is not defined in defaultSendOptions. |
| send(arguments: List&#60;any&#62;, options: SendOptions): Object | Send a transaction to the smart contract and execute its method. This can alter the smart contract state. |
| encodeABI(arguments: List&#60;any&#62;): String | Encodes the ABI for this method. This can be used to send a transaction or call a method, or pass it into another smart contract method as arguments. |
| estimateGas(arguments: List&#60;any&#62;, callObject: Object): String | Estimates the gas that a method execution will take when executed in the Klaytn Virtual Machine. See [klay_call] for more details about callObject.  |

#### ABI

| Method | Description |
| ----------- | ----------- |
| encodeFunctionSignature(method: ContractMethod): String | Encodes the function signature to its ABI signature, which are the first 4 bytes of the sha3 hash of the function name including parameter types. |
| encodeFunctionSignature(functionString: String): String | Encodes the function signature to its ABI signature, which are the first 4 bytes of the sha3 hash of the function name including parameter types. |
| encodeEventSignature(event: ContractEvent): String | Encodes the event signature to its ABI signature, which is the sha3 hash of the event name including input parameter types. |
| encodeEventSignature(eventString: String): String | Encodes the event signature to its ABI signature, which is the sha3 hash of the event name including input parameter types. |
| encodeParameter(type: String, param: any): String | Encodes a parameter based on its type to its ABI representation. It throws an exception if the param is invalid. |
| encodeParameters(types: List&#60;String&#62;, params: List&#60;any&#62;): String | Encodes parameters based on its type to its ABI representation. It throws an exception if the params are invalid. |
| encodeFunctionCall(method: ContractMethod, params: List&#60;any&#62;): String | Encodes a function call using its JSON interface object and given parameters. It throws an exception if the params are invalid. |
| decodeParameter(type: String, encoded: String): String | Decodes an ABI encoded parameter. It throws an exception if the decoding is failed. |
| decodeParameters(types: List&#60;String&#62;, encoded: String): List&#60;String&#62; | Decodes ABI encoded parameters. It throws an exception if the decoding is failed. |
| decodeParameters(method: ContractMethod, encoded: String): List&#60;String&#62; | Decodes ABI encoded parameters. It throws an exception if the decoding is failed. |
| decodeLog(inputs: List&#60;ContractIOType&#62;, data: String, topics: List&#60;String&#62;): JSONObject | Decodes ABI encoded log data and indexed topic data. It throws an exception if the decoding is failed. |
| encodeContractDeploy(constructor: ContractMethod, byteCode: String, params: List&#60;any&#62;): String | Encodes smart contract bytecode with the arguments of the constructor. |
#### KIP7

| Method | Description |
| ----------- | ----------- |
| deploy(tokenInfo: KIP7DeployParams, deployer: String): KIP7 | Deploys the KIP-7 token contract to the Klaytn. |
| clone(): KIP7 | Clones the current KIP7 instance. |
| clone(tokenAddress: address): KIP7 | Clones the current KIP7 instance and set address of contract to tokenAddress parameter. |
| supportInterface(interfaceid: String): Boolean | Return true if this contract implements the interface defined by interfaceId. |
| name(): String | Return the name of the token. |
| symbol(): String | Return the symbol of the token. |
| decimals(): int | Return the number of decimal places the token uses. |
| totalSupply(): BigInteger | Return the total token supply. |
| balanceOf(account: String): BigInteger | Return the balance of the given account address. |
| allowance(owner: String, spender: String): BigInteger | Return the amount of token that spender is allowed to withdraw from owner. |
| isMinter(account: String): Boolean | Return true if the given account is a minter who can issue new KIP7 tokens. |
| isPauser(account: String): Boolean | Return true if the given account is a pauser who can suspend transferring tokens. |
| paused(): Boolean | Return true if the contract is paused, and false otherwise. |
| approve(spender: String, amount: BigInteger): Object | Set the amount of the tokens of the token owner to be spent by the spender. |
| approve(spender: String, amount: BigInteger, sendParam: SendOptions): Object | Set the amount of the tokens of the token owner to be spent by the spender. |
| transfer(recipient: String, amount: BigInteger): Object | Transfers the given amount of the token from the token owner's balance to the recipient. |
| transfer(recipient: String, amount: BigInteger, sendParam: SendOptions): Object | Transfers the given amount of the token from the token owner's balance to the recipient. |
| transferFrom(sender: String, recipient: String, amount: BigInteger): Object | Transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| transferFrom(sender: String, recipient: String, amount: BigInteger, sendParam: SendOptions): Object | Transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| safeTransfer(recipient: String, amount: BigInteger): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. |
| safeTransfer(recipient: String, amount: BigInteger, sendParam: SendOptions): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. |
| safeTransfer(recipient: String, amount: BigInteger, data: String): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. |
| safeTransfer(recipient: String, amount: BigInteger, data: String, sendParam: SendOptions): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. |
| safeTransferFrom(sender: String, recipient: String, amount: BigInteger): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| safeTransferFrom(sender: String, recipient: String, amount: BigInteger, sendParam: SendOptions): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| safeTransferFrom(sender: String, recipient: String, amount: BigInteger, data: String): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| safeTransferFrom(sender: String, recipient: String, amount: BigInteger, data: String, sendParam: SendOptions): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| mint(account: String, amount: BigInteger): Object | Creates the amount of token and issues it to the account, increasing the total supply of token. |
| mint(account: String, amount: BigInteger, sendParam: SendOptions): Object | Creates the amount of token and issues it to the account, increasing the total supply of token. |
| addMinter(account: String): Object | Adds an account as a minter, who are permitted to mint tokens. |
| addMinter(account: String, sendParam: SendOptions): Object | Adds an account as a minter, who are permitted to mint tokens. |
| renounceMinter(): Object | Renounces the right to mint tokens. Only a minter address can renounce the minting right. |
| renounceMinter(sendParam: SendOptions): Object | Renounces the right to mint tokens. Only a minter address can renounce the minting right. |
| burn(amount: BigInteger): Object | Destroys the amount of tokens in the sender's balance. |
| burn(amount: BigInteger, sendParam: SendOptions): Object | Destroys the amount of tokens in the sender's balance. |
| burnFrom(account: String, amount: BigInteger): Object | Destroys the given number of tokens from account. The address who was approved to use the token owner's tokens is expected to execute this token burning transaction. |
| burnFrom(account: String, amount: BigInteger, sendParam: SendOptions): Object | Destroys the given number of tokens from account. The address who was approved to use the token owner's tokens is expected to execute this token burning transaction. |
| addPauser(account: String): Object | Adds an account as a pauser that has the right to suspend the contract. |
| addPauser(account: String, sendParam: SendOptions): Object | Adds an account as a pauser that has the right to suspend the contract. |
| pause(): Object | Suspends functions related to sending tokens. |
| pause(sendParam: SendOptions): Object | Suspends functions related to sending tokens. |
| unpuase(): Object | Resumes the paused contract. |
| unpuase(sendParam: SendOptions): Object | Resumes the paused contract. |
| renouncePauser(): Object | Renounces the right to pause the contract. Only a pauser address can renounce the pausing right. |
| renouncePauser(sendParam: SendOptions): Object | Renounces the right to pause the contract. Only a pauser address can renounce the pausing right. |

#### KIP17

| Method | Description |
| ----------- | ----------- |
| deploy(tokenInfo: KIP17DeployParams, deployer: String): KIP17 | Deploys the KIP-17 token contract to the Klaytn. |
| clone(): KIP17 | Clones the current KIP17 instance. |
| clone(tokenAddress: String): KIP17 | Clones the current KIP17 instance and set address of contract to tokenAddress parameter. |
| supportInterface(interfaceId: String): Boolean | Return true if this contract implements the interface defined by interfaceId. |
| name(): String | Returns the name of the token. |
| symbol(): String | Returns the symbol of the token. |
| tokenURI(tokenId: String): String | Returns the URI for a given token id. |
| totalSupply(): BigInteger | Returns the total number of tokens minted by the contract. |
| tokenOwnerByIndex(owner: String, index: BigInteger): BigInteger | Searches the owner's token list for the given index, and returns the token id of a token positioned at the matched index in the list if there is a match. |
| tokenByIndex(index: BigInteger): BigInteger | Searches the list of all tokens in this contract for the given index, and returns the token id of a token positioned at the matched index in the list if there is a match. |
| balanceOf(account: String): BigInteger | Returns the balance of the given account address. |
| ownerOf(tokenId: BigInteger): String | Returns the address of the owner of the specified token id. |
| getApproved(tokenId: BigInteger): Boolean | Returns the address who was permitted to transfer this token, or 'zero' address, if no address was approved. |
| isApprovedForAll(owner: String, operator: String): Boolean | Returns true if an operator is approved to transfer all tokens that belong to the owner. |
| isMinter(account: String): Boolean | Returns true if the given account is a minter who can issue new tokens in the current contract conforming to KIP-17. |
| paused(): Boolean | Returns true if the contract is paused, and false otherwise. |
| isPauser(account: String): Boolean | Returns true if the given account is a pauser who can suspend transferring tokens. |
| approve(to: String, tokenId: BigInteger): Object | Approves another address to transfer a token of the given token id. |
| approve(to: String, tokenId: BigInteger, sendParam: SendOptions): Object | Approves another address to transfer a token of the given token id. |
| setApprovalForAll(to: String, approved: Boolean): Object | Approves the given operator to, or disallow the given operator, to transfer all tokens of the owner. |
| setApprovalForAll(to: String, approved: Boolean, sendParam: SendOptions): Object | Approves the given operator to, or disallow the given operator, to transfer all tokens of the owner. |
| transferFrom(from: String, to: String, tokenId: BigInteger): Object | Transfers the token of the given token id tokenId from the token owner's balance to another address. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction |
| transferFrom(from: String, to: String, tokenId: BigInteger, sendParam: SendOptions): Object | Transfers the token of the given token id tokenId from the token owner's balance to another address. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction |
| safeTransferFrom(from: String, to: String, tokenId: BigInteger): Object | Safely transfers the token of the given token id tokenId from the token owner's balance to another address. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. |
| safeTransferFrom(from: String, to: String, tokenId: BigInteger, sendParam: SendOptions): Object | Safely transfers the token of the given token id tokenId from the token owner's balance to another address. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. |
| safeTransferFrom(from: String, to: String, tokenId: BigInteger, data: String): Object | Safely transfers the token of the given token id tokenId from the token owner's balance to another address. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. |
| safeTransferFrom(from: String, to: String, tokenId: BigInteger, data: String, sendParam: SendOptions): Object | Safely transfers the token of the given token id tokenId from the token owner's balance to another address. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. |
| addMinter(account: String): Object | Adds an account as a minter, who are permitted to mint tokens. |
| addMinter(account: String, sendParam: SendOptions): Object | Adds an account as a minter, who are permitted to mint tokens. |
| renounceMinter(): Object | Renounces the right to mint tokens. Only a minter address can renounce the minting right. |
| renounceMinter(sendParam: SendOptions): Object | Renounces the right to mint tokens. Only a minter address can renounce the minting right. |
| mint(to: String, tokenId: BigInteger): Object | Creates a token and assigns them to the given account. This method increases the total supply of this token. |
| mint(to: String, tokenId: BigInteger, sendParam: SendOptions): Object | Creates a token and assigns them to the given account. This method increases the total supply of this token. |
| mintWithTokenURI(to: String, tokenId: BigInteger, toeknURI: String): Object | Creates a token with the given uri and assigns them to the given account. This method increases the total supply of this token. |
| mintWithTokenURI(to: String, tokenId: BigInteger, toeknURI: String, sendParam: SendOptions): Object | Creates a token with the given uri and assigns them to the given account. This method increases the total supply of this token. |
| burn(tokenId: BigInteger): Object | Destroys the token of the given token id. |
| burn(tokenId: BigInteger, sendParam: SendOptions): Object | Destroys the token of the given token id. |
| pause(): Object | Suspends functions related to sending tokens. |
| pause(sendParam: SendOptions): Object | Suspends functions related to sending tokens. |
| unpause(): Object | Resumes the paused contract. |
| unpause(sendParam: SendOptions): Object | Resumes the paused contract. |
| addPauser(account: String): Object | Adds an account as a pauser that has the right to suspend the contract. |
| addPauser(account: String, sendParam: SendOptions): Object | Adds an account as a pauser that has the right to suspend the contract. |
| renouncePauser(): Object | Renounces the right to pause the contract. |
| renouncePauser(sendParam: SendOptions): Object | Renounces the right to pause the contract. |

### Utils Layer Class Diagram

The Utils layer provides utility functions.

![0727Utils](https://user-images.githubusercontent.com/32922423/88506767-a9ce9480-d015-11ea-90ac-365d96c40d4a.png)

The Utils class provides basic utility functions required when using Caver, and also converting functions based on `KlayUnit`.

#### utils

| Method | Description |
| ----------- | ----------- |
| isAddress(address: String): Boolean | Checks if a given string is a valid Klaytn address. It will also check the checksum if the address has upper and lowercase letters. |
| isValidPrivateKey(key: String): Boolean | Returns true if privateKey is valid, otherwise it returns false. |
| isKlaytnWalletKey(key: String): Boolean | Returns true if key is in KlaytnWalletKey format, otherwise it returns false. |
| isValidPublicKey(key: String): Boolean | Returns true if publicKey is valid, otherwise it returns false. |
| compressPublicKey(key: String): String | Compresses the uncompressed public key. |
| decompressPublicKey(key: String): String | Decompresses the compressed public key. |
| hashMessage(message: String): String | Hashes message with Klaytn specific prefix: `keccak256("\x19Klaytn Signed Message:\n" + len(message) + message))` |
| parseKlaytnWalletKey(key: String): String[] | Parses KlaytnWalletKey string to an array which includes "private key", "type", "address". |
| isHex(str: String): boolean | Checks if a given string is a HEX string. |
| isHexStrict(str: String): boolean | Checks if a given string is a HEX string. Difference to caver.utils.isHex is that it expects HEX to be prefixed with 0x. |
| addHexPrefix(str: String): String | Returns a 0x-prefixed hex string. If the input is already 0x-prefixed or a non-hex string, the input value is returned as-is. |
| stripHexPrefix(str: String): String | Returns the result with 0x prefix stripped from input. |
| convertToPeb(num: String, unit: String): String | Converts any KLAY value into peb. |
| convertToPeb(num: String, unit: KlayUnit): String | Converts any KLAY value into peb. |
| convertFromPeb(num: String, unit: String): String | Converts any KLAY value from peb. |
| convertFromPeb(num: String, unit: KlayUnit): String | Converts any KLAY value from peb. |
| recover(message: String, signature: KlaySignatureData): String | Recovers the Klaytn address that was used to sign the given data. |
| recover(message: String, signature: KlaySignatureData, preFixed: Boolean): String | Recovers the Klaytn address that was used to sign the given data. |

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
- caver-java - https://github.com/klaytn/caver-java/issues/97

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[accountkey]: https://docs.klaytn.com/klaytn/design/accounts#account-key
[klaytn's account]: https://docs.klaytn.com/klaytn/design/accounts#klaytn-accounts
[klaytn account]: https://docs.klaytn.com/klaytn/design/accounts#klaytn-accounts
[multiple transaction types]: https://docs.klaytn.com/klaytn/design/transactions#klaytn-transactions
[basic transactions]: https://docs.klaytn.com/klaytn/design/transactions/basic
[fee delegation transactions]: https://docs.klaytn.com/klaytn/design/transactions/fee-delegation
[partial fee delegation transactions]: https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation
[klaytn design - transactions]: https://docs.klaytn.com/klaytn/design/transactions
[kip-7]: ./kip-7.md
[kip-17]: ./kip-17.md
[klay]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay
[node api of klay namespace]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay
[net]: https://docs.klaytn.com/bapp/json-rpc/api-references/network
[node api of net namespace]: https://docs.klaytn.com/bapp/json-rpc/api-references/network
[json-rpc apis]: https://docs.klaytn.com/bapp/json-rpc/api-references
[klay_logs]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay/filter#klay_getlogs
[klay_call]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay/transaction#klay_call
