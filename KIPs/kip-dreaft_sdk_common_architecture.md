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
  - [Account Layer](#account-layer)
  - [Wallet Layer](#wallet-layer)
  - [Transaction Layer](#transaction-layer)
  - [RPC Layer](#rpc-layer)
  - [Contract, ABI, KCT Layer](#contract-abi-kct-layer)
  - [Utils Layer](#utils-layer)
- [Example Usage of the Common Architecture](#example-usage-of-the-common-architecture)
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
| Account | A data structure representing a Klaytn Account. It contains information like balance, nonce, public key(s), etc. Note that the public key(s) of the account can be changed in Klaytn because the public key(s) and the account address are decoupled. Please refer to [klaytn account] for more detail.  |
| Account key | A data structure representing various Klaytn account key types. Please refer to [accountkey] for more detail. |
| Keyring | A data structure containing Klaytn's account address and private key(s). It is used to sign a transaction. |
| Keyring container | A data structure containing multiple keyrings. |
| Wallet | A synonym of the keyring container. A wallet is a data structure containing multiple keyrings. |
| [Transaction](https://docs.klaytn.com/klaytn/design/transactions#transactions-overview) | A data structure sent between nodes that changes the state of the blockchain. Klaytn provides [multiple transaction types] that empower Klaytn with new capabilities and optimizations for memory footprint and performance. |
| Raw transaction | An RLP-encoded string of a transaction. |
| [JSON-RPC](https://www.jsonrpc.org/specification) | A stateless, light-weight remote procedure call (RPC) protocol. It uses JSON as a data format. |
| Contract | A computer program or a transaction protocol which is intended to automatically execute, control or document legally relevant events and actions according to the terms of a contract or an agreement. You can deploy a smart contract or execute a smart contract that has already been deployed to Klaytn through a transaction. |
| ABI | The Application Binary Interface(ABI) to communicate between two binary program modules. |
| [KCT (Klaytn Compatible Token)](http://kips.klaytn.com/token) | A special type of a smart contract that implements token specifications defined in [the KCT section of Klaytn Improvement Proposals](http://kips.klaytn.com/token). |

### Overview of the Common Architecture

This is the overview of the common architecture of Klaytn SDK.

![0811All](https://user-images.githubusercontent.com/32922423/89860556-af63d700-dbde-11ea-815a-433aef0ae806.png)

### Layer Diagram of the Common Architecture

Below diagram shows the layers of the common architecture. Components belonging to each layer are represented inside the layer box.

![layerDiagram](https://user-images.githubusercontent.com/32922423/85986440-355d0180-ba27-11ea-8475-afe7638e6ffb.png)

The `KCT` layer allows you to interact with Klaytn compatible token (KCT) contracts (e.g. [KIP-7] or [KIP-17]). This is implemented by extending the `Contract` class in the `Contract` layer.

The `Contract` layer allows you to interact with smart contracts on the Klaytn.

The `ABI` layer provides the functions to encode and decode parameters based on ABI.

The `Transaction` layer contains classes of Klaytn transaction types, `TransactionDecoder`, and `TransactionHasher`. The `TransactionDecoder` class decodes the RLP-encoded transaction string. The `TransactionHasher` class calculates the hash of the transaction.

The `Wallet` layer contains keyring classes (`SingleKeyring`, `MultipleKeyring`, and `RoleBasedKeyring`) and `KeyringContainer` class that contains multiple keyrings. The `KeyringContainer` class acts as an "in-memory wallet" that stores the Keyring instances.

The `Account` layer contains an `Account` class that stores information needed when updating the [AccountKey] of the account in the Klaytn.

Also, the `RPC` layer includes the `Klay` class, which is responsible for rpc calls of the klay namespace, and the `Net` class, which is responsible for rpc calls of the net namespace.

Finally, the `Utils` layer contains the `Utils` class that provides utility functions.

From the next chapter, each layer is described in detail.

### Account Layer

The `Account` layer provides functionality related to updating the [AccountKey] of the Klaytn account.

![0811Account](https://user-images.githubusercontent.com/32922423/89860635-e508c000-dbde-11ea-8c2f-b755212f3556.png)

`Account` is a class that represents a Klaytn account. It contains information needed to update the [AccountKey] of the account in the Klaytn. It has `address` and `accountKey` as member variables. The `accountKey` can be an instance of `AccountKeyLegacy`, `AccountKeyPublic`, `AccountKeyFail`, `AccountKeyWeightedMultiSig`, and `AccountKeyRoleBased` depending on the key.

An `Account` instance is injected into the `account` field of the AccountUpdate transaction types (`AccountUpdate`, `FeeDelegatedAccountUpdate`, and `FeeDelegatedAccountUpdateWithRatio`). When an AccountUpdate transaction is successfully processed in Klaytn, the account key of the [Klaytn account] is updated with the `accountKey` defined in the `Account` instance.

Interface for AccountKey is defined as `IAccountKey`, and account key classes (`AccountKeyLegacy`, `AccountKeyPublic`, `AccountKeyFail`, `AccountKeyWeightedMultiSig` and `AccountKeyRoleBased`) implement IAccountKey.

`WeightedMultiSigOptions` is for `AccountKeyWeightedMultiSig` where the threshold and the weight of each key are defined.

The `AccountKeyDecoder` class decodes the RLP-encoded string using the decode function implemented in each AccountKey class.

#### IAccountKey

`IAccountKey` is the interface of AccountKey. All AccountKey classes must implement `IAccountKey`.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| getRLPEncoding(): String | Returns an RLP-encoded string of AccountKey. AccountKey classes below implements `IAccountKey`, so this function must be implemented. |

#### AccountKeyLegacy

`AccountKeyLegacy` is a class representing [AccountKeyLegacy](https://docs.klaytn.com/klaytn/design/accounts#accountkeylegacy). It is used for the account having an address derived from the corresponding key pair.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyLegacy | Decodes an RLP-encoded string of AccountKeyLegacy and returns an `AccountKeyLegacy` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyLegacy. |

#### AccountKeyPublic

`AccountKeyPublic` is a class representing [AccountKeyPublic](https://docs.klaytn.com/klaytn/design/accounts#accountkeypublic). It is used for accounts having one public key.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| publicKey: String | A public key string. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyPublic | Decodes an RLP-encoded string of AccountKeyPublic and returns an `AccountKeyPublic` instance. It throws an exception if the decoding is failed. |
| fromXYPoint(x: String, y: String): AccountKeyPublic | Creates and returns an `AccountKeyPublic` instance from x and y points. It throws an exception if the x and y points are invalid. |
| fromPublicKey(publicKey: String): AccountKeyPublic | Creates and returns an `AccountKeyPublic` instance from public key string. It throws an exception if the public key is invalid. |
| getXYPoint(): String[] | Returns the x and y points of the public key. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyPublic. |

#### AccountKeyFail

`AccountKeyFail` is a class representing [AccountKeyFail](https://docs.klaytn.com/klaytn/design/accounts#accountkeyfail). It is used when all transactions sent from the account are expected to be failed.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyFail | Decodes an RLP-encoded string of AccountKeyFail and returns an `AccountKeyFail` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyFail. |

#### AccountKeyWeightedMultiSig

`AccountKeyWeightedMultiSig` is a class representing [AccountKeyWeightedMultiSig](https://docs.klaytn.com/klaytn/design/accounts#accountkeyweightedmultisig). It is an account key type containing a threshold and WeightedPublicKeys which contains a list whose item is composed of a public key and its weight.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| threshold: int | A validation threshold. To be a valid transaction, the transaction must contain valid signatures equal to or more than the threshold. |
| weightedPublicKey: List&#60;WeightedPublicKey&#62; | A list of weighted public keys. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyWeightedMultiSig | Decodes an RLP-encoded string of AccountKeyWeightedMultiSig and returns an `AccountKeyWeightedMultiSig` instance. It throws an exception if the decoding is failed. |
| fromPublicKeysAndOptions(pubArray: String[], options: WeightedMultiSigOptions): AccountKeyWeightedMultiSig | Creates and returns an `AccountKeyWeightedMultiSig` instance with public key strings in `pubArray` and the options defining the threshold and the weight of each key in `WeightedMultiSigOptions `. It throws an exception if the options or public keys for accountKeyWeightedMultiSig are invalid. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyWeightedMultiSig. |

#### WeightedPublicKey

`WeightedPublicKey` is a class storing a public key with its weight. It is used for AccountKeyWeightedMultiSig.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| publicKey: String | A public key string. |
| weight: int | A weight of the public key. |

##### Methods

None

#### WeightedKeyMultiSigOptions

`WeightedKeyMultiSigOptions` is a class that defines the threshold and the weight of each public key for AccountKeyWeightedMultiSig.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| threshold: int | A validation threshold. |
| weighted: List&#60;int&#62; | A list of weights of public keys. |

##### Methods

None

#### AccountKeyRoleBased

`AccountKeyRoleBased` is a class representing [AccountKeyRoleBased](https://docs.klaytn.com/klaytn/design/accounts#accountkeyrolebased). It is used to set different key pairs to different roles in an account.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| accountKeys: List&#60;IAccountKey&#62; | A list of keys to be used for each role. An item of the list represents a role. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): AccountKeyRoleBased | Decodes an RLP-encoded string of AccountKeyRoleBased and returns an `AccountKeyRoleBased` instance. It throws an exception if the decoding is failed. |
| fromRoledPublicKeysAndOptions(pubArray: List&#60;String[]&#62;, options: List&#60;WeightedMultiSigOptions&#62;): AccountKeyRoleBased | Creates and returns an instance of AccountKeyRoleBased with public key strings for each role and the option that defines threshold and weight of each key. It throws an exception if the public key(s) for each role or options are invalid. |
| fromRoledPublicKeysAndOptions(pubArray: List&#60;String[]&#62;): AccountKeyRoleBased | Creates and returns an instance of AccountKeyRoleBased with public key strings for each role. This function assumes that all the values of the threshold and weights are set to be one. |
| getRLPEncoding(): String | Returns the RLP-encoded string of AccountKeyRoleBased. |

#### AccountKeyDecoder

`AccountKeyDecoder` provides the function to decode RLP-encoded accountKey strings.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncodedKey: String): IAccountKey | Decodes an RLP-encoded string of any class that inherits `IAccountKey` and returns the corresponding account key class. This function is useful when decoding an RLP-encoded string of any account key types. It throws an exception if the decoding is failed. |

#### Account

`Account` is a class that represents a Klaytn account. It contains information needed to update the AccountKey of the account in the Klaytn.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| address: String | The address of an account to be updated. |
| accountKey: IAccountKey | The new accountKey to be used in the given account. This can be an instance of [AccountKeyLegacy](#accountkeylegacy), [AccountKeyPublic](#accountkeypublic), [AccountKeyFail](#accountkeyfail), [AccountKeyWeightedMultiSig](#accountkeyweightedmultisig) and [AccountKeyRoleBased](#accountkeyrolebased). |

##### Methods

| Method | Description |
| ----------- | ----------- |
| create(address: String, publicKey: String): Account | Generates an Account instance with an address and a public key string. |
| create(address: String, pubKeys: String[]): Account | Generates an Account instance with an address and public key strings. A threshold of 1 and a weight of 1 for each key will be used as a default option. |
| create(address: String, pubKeys: String[], options: WeightedMultiSigOptions): Account | Generates an Account instance with an address and public key strings and options that defines the threshold and the weight of each key. |
| create(address: String, roleBasedPubKeys: List&#60;String[]&#62;): Account | Creates an Account instance with an array of public keys defined for each role. A default option with a threshold of 1 and a weight of 1 for each key will be used for each role. |
| create(address: String, roleBasedPubKeys: List&#60;String[]&#62;, options: List&#60;WeightedMultiSigOptions&#62;): Account | Creates an Account instance with an array of public keys and an array of options defined for each role. |
| createFromRLPEncoding(address: String, rlpEncodedKey: String): Account | Creates and returns an Account instance with an address and RLP-encoded string. It throws an exception if the RLP-encoded string is invalid. |
| createWithAccountKeyLegacy(address: String): Account | Creates and returns an Account instance which has AccountKeyLegacy as an accountKey. It throws an exception if the address string is invalid. |
| createWithAccountKeyPublic(address: String, publicKey: String): Account | Creates and returns an Account instance which has AccountKeyPublic as an accountKey. It throws an exception if the address string or public key string is invalid. |
| createWithAccountKeyFail(address: String): Account | Creates and returns an Account instance which has AccountKeyFail as an accountKey. It throws an exception if the address string is invalid. |
| createWithAccountKeyWeightedMultiSig(address: String, publicKeys: String[]): Account | Creates and returns an Account instance which has AccountKeyWeightedMultiSig as an accountKey. The options required for AccountKeyWeightedMultiSig use default values (threshold:1, weight of each key: 1). It throws an exception if the address string or public key strings are invalid. |
| createWithAccountKeyWeightedMultiSig(address: String, publicKeys: String[], options: WeightedMultiSigOptions): Account | Creates and returns an Account instance which has AccountKeyWeightedMultiSig as an accountKey. It throws an exception if the address string, public key strings or options are invalid. |
| createWithAccountKeyRoleBased(address: String, roleBasedPubKeys: List&#60;String[]&#62;): Account | Creates and returns an Account instance which has AccountKeyRoleBased as an accountKey. If multiple keys are used among the defined roles, options use the default value (threshold:1, weight of each key: 1). It throws an exception if the address string or public key strings are invalid. |
| createWithAccountKeyRoleBased(address: String, roleBasedPubKeys: List&#60;String[]&#62;, options: List&#60;WeightedMultiSigOptions&#62;): Account | Creates and returns an Account instance which has AccountKeyRoleBased as an accountKey. It throws an exception if the address string, public key strings or options are invalid. |
| getRLPEncodingAccountKey(): String | Returns the RLP-encoded string of the account key in the Account instance. |

### Wallet Layer

The `Wallet` layer allows the user to sign a message or a transaction through the Caver with a [Klaytn account].

![0811Wallet](https://user-images.githubusercontent.com/32922423/89861019-c8b95300-dbdf-11ea-8aa6-30015a33100d.png)

In the Wallet layer, an abstract class `AbstractKeyring` is defined, and `SingleKeyring`, `MultipleKeyring` and `RoleBasedKeyring` are implemented by extending `AbstractKeyring`. The `AbstractKeyring` class defines abstract methods that Keyring classes must implement.

`SingleKeyring` is a class that uses only one private key, and `MultipleKeyring` is a class that uses multiple private keys. `RoleBasedKeyring` is a class that uses different private key(s) for each role, and the `keys` member variable is a 2D array in which keys to be used for each role are defined.

Each keyring class uses the `PrivateKey` class, which has one private key as a member variable.

`KeyringFactory` provides static methods to create `SingleKeyring`, `MultipleKeyring` or `RoleBasedKeyring`.

`MessageSigned` is a structure that contains the result of signing a message, and it is used as a result of the `signMessage` function.

`SignatureData` is a structure that stores a signature.

`Keystore` is a class that contains encrypted keyring. The internally defined value differs depending on the keystore version, see [KIP-3](./kip-3.md).

`KeyringContainer` is an "in-memory wallet" class that manages keyring instances. It manages the keyring instances based on their addresses.

#### PrivateKey

`PrivateKey` is a class that contains a private key string.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| privateKey: String | The private key string. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| sign(txHash: String, chainId: String): SignatureData | Signs the transaction based on the transaction hash and chain id and returns the signature. |
| sign(txHash: String, chainId: int): SignatureData | Signs the transaction based on the transaction hash and chain id and returns the signature. |
| signMessage(messageHash: String): SignatureData | Signs the message with the Klaytn-specific prefix and returns the signature. |
| getPublicKey(compressed: Boolean): String | Returns the compressed public key string if compressed is true. It returns the uncompressed public key string otherwise. |
| getDerivedAddress(): String | Returns the derived address from the private key string. |

#### AbstractKeyring

`AbstractKeyring` is an abstract class of keyring classes. It stores the account address and private key(s). All keyring classes extends the `AbstractKeyring` class.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| address: String | The address of the account. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| sign(txHash: String, chainId: int, role: int): List&#60;SignatureData&#62; | Signs the transaction using the key(s) specified by the role, and it returns the signature. It is defined as an abstract method, and it must be implemented in all keyring classes that extend `AbstractKeyring`. |
| sign(txHash: String, chainId: int, role: int, index: int): SignatureData | Signs the transaction using the key(s) specified by the role and the index, and it returns the signature. It is defined as an abstract method, and it must be implemented in all keyring classes that extend `AbstractKeyring`. |
| sign(txHash: String, chainId: String, role: int): List&#60;SignatureData&#62; | Signs the transaction using the key(s) specified by the role and returns the signatures. |
| sign(txHash: String, chainId: String, role: int, index: int): SignatureData | Signs the transaction using a key specified by the role and the index, and it returns the signature. |
| signMessage(message: String, role: int): MessageSigned | Signs the transaction using the key(s) specified by the role, and it returns the signature. It is defined as an abstract method, and it must be implemented in all keyring classes that extend `AbstractKeyring`. |
| signMessage(message: String, role: int, index: int): MessageSigned | Signs the transaction using the key(s) specified by the role and the index, and it returns the signature. It is defined as an abstract method, and it must be implemented in all keyring classes that extend `AbstractKeyring`. |
| encrypt(password: String): Object | Encrypts a Keyring instance in the keystore v4 format. |
| encrypt(password: String, options: Object): Object | Encrypts a Keyring instance in the [keystore v4 format](http://kips.klaytn.com/KIPs/kip-3). In options, the encrypt method (scrypt, pbkdf2, etc.) and parameters used for encrypting (dklen, salt, etc.) can be defined. It is defined as an abstract method, and it must be implemented in all keyring classes that extend `AbstractKeyring`. |
| encryptV3(password: String): Object | Encrypts a Keyring instance in the keystore v3 format. |
| encryptV3(password: String, options: Object): Object | Encrypts a Keyring instance with keystore v3 format. In options, the encrypt method (scrypt, pbkdf2, etc.) and parameters used for encrypting (dklen, salt, etc.) can be defined. |
| copy(): AbstractKeyring | Duplicates the Keyring instance and returns it. It is defined as an abstract method, and it must be implemented in all keyring classes that extend `AbstractKeyring`. |
| getKlaytnWalletKey(): String | Returns the KlaytnWalletKey string. It throws an exception by default in `AbstractKeyring`. |
| isDecoupled(): Boolean | Returns true if keyring has a decoupled key. |

#### SingleKeyring

`SingleKeyring` is a class that stores the account address and a private key.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| key: PrivateKey | An instance of `PrivateKey` containing one private key. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| getPublicKey(): String | Returns the public key string. |
| getKeyByRole(role): PrivateKey | Returns the keys specified by the role. SingleKeyring always returns a same key. |
| toAccount(): Account | Returns an Account instance. |

#### MultipleKeyring

`MultipleKeyring` is a class that stores an account address and multiple private keys.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| keys: List&#60;PrivateKey&#62; | An array of PrivateKey instances containing one private key. `keys` can contain up to ten PrivateKey instances. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| getPublicKey(): List&#60;String&#62; | Returns the public key strings. |
| getKeyByRole(role): List&#60;PrivateKey&#62; | Returns the keys specified by the role. |
| toAccount(): Account | Returns an Account instance. A default option with a threshold of 1 and a weight of 1 for each key will be used. |
| toAccount(options: WeightedMultiSigOptions): Account | Returns an Account instance with the given options. It throws an exception if the options is invalid. |

#### RoleBasedKeyring

`RoleBasedKeyring` is a class that stores the account address and the private keys for each role in the form of an array.
`RoleBasedKeyring` defines keys which are implemented as a two-dimensional array (empty keys looks like [ [], [], [] ]) that can include multiple keys for each role. The each array element defines the private key(s) for roleTransactionKey, roleAccountUpdateKey, and roleFeePayerKey, respectively.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| keys: List&#60;List&#60;PrivateKey&#62;&#62; | A two-dimensional array that defines the keys used for each role. Each role includes PrivateKey instance(s). The each array element defines the private key(s) for roleTransactionKey, roleAccountUpdateKey, and roleFeePayerKey, respectively. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| getPublicKey(): List&#60;List&#60;String&#62;&#62; | Returns the public key strings for all roles. |
| getKeyByRole(role): List&#60;PrivateKey&#62; | Returns the private keys for all roles. |
| toAccount(): Account | Returns an Account instance. A default option with a threshold of 1 and a weight of 1 for each key will be used for each role. |
| toAccount(options: List&#60;WeightedMultiSigOptions&#62;): Account | Returns an Account instance with the given options. It throws an exception if the options is invalid. |

#### SignatureData

`SignatureData` is a class that contains a signature string.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| v: String | ECDSA recovery id. |
| r: String | ECDSA signature r. |
| s: String | ECDSA signature s. |

##### Methods

None

#### MessageSigned

`MessageSigned` stores the result of signing a message.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| messageHash: String | The hashed message string. |
| signatureData: List<SignatureData> | An array of signatures. |
| message: String | The original message used for signing. |

##### Methods

None

#### KeyringFactory

`KeyringFactory` provides functions to create Keyring (SingleKeyring, MultipleKeyring, and RoleBasedKeyring) instances.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| generate(): SingleKeyring | Generates a SingleKeyring instance with a randomly generated private key. |
| generate(entropy: String): SingleKeyring | Generates a SingleKeyring instance with a randomly generated private key based on the entropy. |
| generateSingleKey(): String | Generates a private key string. |
| generateSingleKey(entropy: String): String | Generates a private key string based on the entropy. |
| generateMultipleKeys(num: int): List&#60;String&#62; | Generates private key strings. |
| generateMultipleKeys(num: int, entropy: String): List&#60;String&#62; | Generates private key strings based on the entropy. |
| generateRoleBasedKeys(numArr: List&#60;int&#62;): List&#60;List&#60;String&#62;&#62; | Generates and returns private keys for each role. The number of keys for each role is defined in numArr. |
| generateRoleBasedKeys(numArr: List&#60;int&#62;, entropy: String): List&#60;List&#60;String&#62;&#62; | Generates and returns private keys for each role based on the entropy. The number of keys for each role is defined in numArr. |
| create(address: String, key: String): SingleKeyring | Creates and returns a SingleKeyring instance with an address and a private key string. It throws an exception if the address string or private key string is invalid. |
| create(address: String, keys: String[]): MultipleKeyring | Creates a MultipleKeyring instance with an address and private key strings. It throws an exception if the address string or private key strings are invalid. |
| create(address: String, roleBasedKeys: List&#60;String[]&#62;): RoleBasedKeyring | Creates a RoleBasedKeyring instance with an address and private key strings by roles. It throws an exception if the address string or private key strings are invalid. |
| createFromPrivateKey(key: String): SingleKeyring | Creates a SingleKeyring instance from a private key string or a KlaytnWalletKey. It throws an exception if the private key string is invalid. |
| createFromKlaytnWalletKey(klaytnWalletKey: String): SingleKeyring | Creates a SingleKeyring instance from a KlaytnWalletKey string. It throws an exception if the KlaytnWalletKey is invalid. |
| createWithSingleKey(address: String, key: String): SingleKeyring | Creates a SingleKeyring instance from an address and a private key string. It throws an exception if the address string or the private key string is invalid. |
| createWithMultipleKey(address: String, keys: String[]): MultipleKeyring | Creates a MultipleKeyring instance from an address and the private key strings. It throws an exception if the address string or the private key strings are invalid. |
| createWithRoleBasedKey(address: String, roleBasedKeys: List&#60;String[]&#62;): RoleBasedKeyring | Creates a RoleBasedKeyring instance from an address and a 2D array of which each array element contains keys defined for each role. It throws an exception if the address string or the private key strings are invalid. |
| decrypt(keystore: Object, password: String): Keyring | Decrypts a keystore v3 or v4 JSON and returns the decrypted keyring instance. It throws an exception if the decryption is failed. |

#### KeyringContainer

`KeyringContainer` is a class that contains SingleKeyring, MultipleKeyring, and RoleBasedKeyring instances based on the address.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| length: int | The number of keyrings in the `KeyringContainer` instance. |
| addressKeyringMap: Map<String, AbstractKeyring> | A Map that has an account address as a key and a Keyring instance corresponding to that address as a value. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| generate(num: int, entropy: String): List&#60;String&#62; | Generates `num` SingleKeyring instances and stores them in the keyringContainer. The randomness of the private keys are determined by the given entropy. |
| add(keyring: AbstractKeyring): AbstractKeyring | Adds the given keyring instance to the `KeyringContainer` instance. It throws an exception if the address of the given keyring instance already exists in the `KeyringContainer` instance. |
| newKeyring(address: String, privateKeyString: String): AbstractKeyring | Creates a `SingleKeyring` instance with given parameters and adds it to the `KeyringContainer` instance. It returns the newly added keyring instance. It throws an exception if the address or private key string is invalid. |
| newKeyring(address: String, privateKeyArray: List&#60;String&#62;): AbstractKeyring | Creates a `MultipleKeyring` instance with given parameters and adds it to the `KeyringContainer` instance. It returns the newly added keyring instance. It throws an exception if the address string or private key strings are invalid. |
| newKeyring(address: String, roleBasedPrivateKeyArray: List&#60;List&#60;String&#62;&#62;): AbstractKeyring | Creates a `RoleBasedKeyring` instance with given parameters and adds it to the `KeyringContainer` instance. It returns the newly added keyring instance. It throws an exception if the address string or private key strings are invalid. |
| updateKeyring(keyring: AbstractKeyring): AbstractKeyring | Replaces the keyring instance having the same address with the given keyring in the parameter. It throws an exception if the matching keyring is not found. |
| getKeyring(address: String): AbstractKeyring | Returns the keyring instance corresponding to the address. |
| sign(address: String, transaction: AbstractTransaction): AbstractTransaction | Signs the transaction as a sender of the transaction and appends signatures in the transaction object using the keyring associated with the given address in the `KeyringContainer` instance. This method will use all the private keys in the keyring. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance or if the address received as a parameter and the sender of the actual transaction do not match. |
| sign(address: String, transaction: AbstractTransaction, index: int): AbstractTransaction | Signs the transaction as a sender of the transaction and appends a signature in the transaction object using the keyring associated with the given address in the `KeyringContainer` instance. This method uses the private key at the index in the keyring. It throws an exception if the matched keyring cannot be found in the `KeyringContainer` instance or if the address received as a parameter and the sender of the actual transaction do not match. |
| sign(address: String, transaction: AbstractTransaction, hasher: Function): AbstractTransaction | Signs the transaction as a sender of the transaction and appends signatures in the transaction object using the keyring associated with the given address in the `KeyringContainer` instance. This method will use all the private keys. When obtaining the transaction hash, `hasher` is used. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance or if the address received as a parameter and the sender of the actual transaction do not match. |
| sign(address: String, transaction: AbstractTransaction, index: int, hasher: Function): AbstractTransaction | Signs the transaction as a sender of the transaction and appends a signature in the transaction object using the keyring associated with the given address in the `KeyringContainer` instance. This method uses the private key at `index` in the keyring. When obtaining the transaction hash, `hasher` is used. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance or if the address received as a parameter and the sender of the actual transaction do not match. |
| signAsFeePayer(address: String, transaction: AbstractTransaction): AbstractTransaction | Signs the transaction as a fee payer of the transaction and appends signatures in the transaction object using the keyring associated with the given address in the `KeyringContainer` instance. This method will use all the private keys in the keyring. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance or if the address received as a parameter and the fee payer of the actual transaction do not match. |
| signAsFeePayer(address: String, transaction: AbstractTransaction, index: int): AbstractTransaction | Signs the transaction as a fee payer of the transaction and appends a signature in the transaction object using the keyring associated with the given address in  the `KeyringContainer` instance. This method uses the private key at `index` in the keyring. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance or if the address received as a parameter and the fee payer of the actual transaction do not match. |
| signAsFeePayer(address: String, transaction: AbstractTransaction, hasher: Function): AbstractTransaction | Signs the transaction as a fee payer of the transaction and appends signatures in the transaction object using the keyring associated with the given address in the `KeyringContainer` instance. This method will use all the private keys. When obtaining the transaction hash, `hasher` is used. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance or if the address received as a parameter and the fee payer of the actual transaction do not match. |
| signAsFeePayer(address: String, transaction: AbstractTransaction, index: int, hasher: Function): AbstractTransaction | Signs the transaction as a fee payer of the transaction and appends a signature in the transaction object using the the keyring associated with the given address in the `KeyringContainer` instance. This method uses the private key at `index` in the keyring. When obtaining the transaction hash, `hasher` is used. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance or if the address received as a parameter and the fee payer of the actual transaction do not match. |
| signMessage(address: String, data: String, role: int): MessageSigned | Signs the message with the Klaytn-specific prefix using the keyring associated with the given address in the `KeyringContainer` instance. This method will use all the private keys in the keyring. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance. |
| signMessage(address: String, data: String, role: int, index: int): MessageSigned | Signs the message with Klaytn-specific prefix using the keyring associated with the given address in the `KeyringContainer` instance. This method uses the private key at `index` in the keyring. It throws an exception if the keyring to be used for signing cannot be found in the `KeyringContainer` instance. |
| remove(address: String): Boolean | Deletes the keyring associated with the given address from the `KeyringContainer` instance. |

### Transaction Layer

The `Transaction` layer provides classes related to Klaytn transactions.

![0811Transaction](https://user-images.githubusercontent.com/32922423/89860534-a410ab80-dbde-11ea-9bc1-a69991482d25.png)

Abstract classes (`AbstractTransaction`, `AbstractFeeDelegatedTransaction` and `AbstractFeeDelegatedWithRatioTrasnaction`) are defined in the Transaction layer to declare common attributes and methods.

`AbstractTransaction` defines variables and methods commonly used in all transactions. In addition, abstract methods that must be implemented in classes that extend this class are also defined. `AbstractFeeDelegatedTransaction` extends `AbstractTransaction`, and it defines variables and methods commonly used in fee delegation and partial fee delegation transactions. `AbstractFeeDelegatedWithRatioTransaction` extends `AbstractFeeDelegatedTransaction`, and it defines variables commonly used in partial fee delegation transactions.

Among the transaction types used in Klaytn, [Basic transactions] are implemented by extending `AbstractTransaction`. [Fee delegation transactions] are implemented by extending `AbstractFeeDelegatedTransaction`, [Partial fee delegation transactions] are implemented by extending `AbstractFeeDelegatedWithRatioTransaction`.

The `TransactionDecoder` class decodes the RLP-encoded string using the `decode` method implemented in each transaction class.

`TransactionHasher` is a class that calculates the hash of a transaction. It provides a function that calculates a hash when a transaction is signed as a sender or a fee payer. It is implemented based on [Klaytn Design - Transactions].

#### AbstractTransaction

`AbstractTransaction` is an abstract class that represents transaction types defined in [Basic Transaction](https://docs.klaytn.com/klaytn/design/transactions/basic). All basic transaction classes extends `AbstractTransaction`.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| type: String | The type string of the transaction. |
| from: String | The address of the sender. |
| nonce: String | A value used to uniquely identify a sender’s transaction. If omitted when creating a transaction, [klay_getTransactionCount](https://docs.klaytn.com/bapp/json-rpc/api-references/klay/account#klay_gettransactioncount) will be used to set an appropriate nonce. |
| gas: String | The maximum amount of the transaction fee allowed to use. |
| gasPrice: String | A multiplier to get how much the sender will pay in KLAY. If omitted when create a transaction, [klay_gasPrice](https://docs.klaytn.com/bapp/json-rpc/api-references/klay/config#klay_gasprice) will be used to set this value. |
| signatures: List<SignatureData> | An array of signatures. The result of signing the transaction is appended to this signatures. When appending a signature, duplicate signatures are not appended. |
| chainId: String | The chain id of the Klaytn network. If omitted when creating a transaction, [klay_chainID](https://docs.klaytn.com/bapp/json-rpc/api-references/klay/config#klay_chainid) will be used to set this value. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| getRLPEncoding(): String | Returns an RLP-encoded transaction string. It is defined as an abstract method, and must be implemented in all transaction classes that extend `AbstractTransaction`. |
| getCommonRLPEncodingForSignature(): String | Encodes and returns the values needed to sign each transaction. For example, in the case of value transfer transactions, if SigRLP is `encode([encode([type, nonce, gasPrice, gas, to, value, from]), chainid, 0, 0])`, among them, the RLP-encoded values of the transaction required for signing is `encode([type, nonce, gasPrice, gas, to, value, from])`. This function is used in getRLPEncodingForSignature or getRLPEncodingForFeePayerSignature function. It is defined as an abstract method, and must be implemented in all transaction classes that extend `AbstractTransaction`. |
| sign(keyString: String): AbstractTransaction | Signs the transaction as a sender with the private key (or KlaytnWalletKey) and appends signatures to the transaction object. |
| sign(keyString: String, hasher: Function): AbstractTransaction | Signs the transaction as a sender with the private key (or KlaytnWalletKey) and appends signatures to the transaction object. The `hasher` function will be used when getting the hash of a transaction. |
| sign(keyring: AbstractKeyring): AbstractTransaction | Signs the transaction as a sender with all the private keys in the given keyring and appends signatures to the transaction object. |
| sign(keyring: AbstractKeyring, index: int): AbstractTransaction | Signs the transaction as a sender with the private key specified by the given keyring and index. It appends the result signature into the transaction object. |
| sign(keyring: AbstractKeyring, hasher: Function): AbstractTransaction | Signs the transaction as a sender with the private keys in the given keyring. When obtaining the transaction hash, `hasher` is used. |
| sign(keyring: AbstractKeyring, index: int, hasher: Function): AbstractTransaction | Signs the transaction as a sender with the a private key specified by the given keyring and index. It appends signatures into the transaction object. The `hasher` function will be used when getting the transaction hash. |
| appendSignatures(sig: SignatureData): void | Appends the given signature to the transaction instance. |
| appendSignatures(sig: List&#60;SignatureData&#62;): void | Appends the given signatures to the transaction instance. |
| combineSignedRawTransactions(rlpEncoded: List&#60;String&#62;): String | Collects signatures in RLP-encoded transaction strings in the given array, combines them into this transaction instance, and returns an RLP-encoded transaction string which includes all signatures. If the contents of the transaction are different from this transaction instance, it fails. |
| getTransactionHash(): String | Returns the transaction hash of this transaction instance. |
| getSenderTxHash(): String | Returns a senderTxHash of this transaction instance. |
| getRawTransaction(): String | Returns a rawTransaction string (an RLP-encoded transaction string). This function is identical to `getRLPEncoding()`. |
| getRLPEncodingForSignature(): String | Returns an RLP-encoded transaction string to make the signature of the sender. |
| fillTransaction(): void | Fills in the optional variables (nonce, gasPrice, and chainId) in transaction. |

#### AbstractFeeDelegatedTransaction

`AbstractFeeDelegatedTransaction` is an abstract class that represents transaction types defined in [fee delegation transaction](https://docs.klaytn.com/klaytn/design/transactions/fee-delegation). `AbstractFeeDelegatedTransaction` is implemented by extending `AbstractTransaction`. All fee delegation transaction classes are implemented by extending `AbstractFeeDelegatedTransaction`.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| feePayer: String | The address of the fee payer. |
| feePayerSignatures: List<SignatureData> | An array of signatures of fee payers. The result of signing the transaction as a fee payer is appended to this array. If the duplicated fee payer signature is added, it fails. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| signAsFeePayer(keyString: String): AbstractFeeDelegatedTransaction | Signs the transaction as a fee payer with a private key string (or KlaytnWalletKey) and appends the fee payer signature into the transaction object. |
| signAsFeePayer(keyString: String, hasher: Function): AbstractFeeDelegatedTransaction | Signs the transaction as a fee payer with a private key string (or KlaytnWalletKey) and appends the fee payer signature in the transaction object. The `hasher` function will be used when getting the hash of the transaction. |
| signAsFeePayer(keyring: AbstractKeyring): AbstractFeeDelegatedTransaction | Signs the transaction as a fee payer with private keys in `keyring` and appends the fee payer signatures in the transaction object. If the fee payer address of this transaction instance differs from the address of `keyring`, it throws an exception. |
| signAsFeePayer(keyring: AbstractKeyring, index: int): AbstractFeeDelegatedTransaction | Signs the transaction as a fee payer with a private key specified by `keyring` and `index`. It appends the fee payer signatures into the transaction object. If the fee payer address of this transaction instance differs from the address of `keyring`, it throws an exception. |
| signAsFeePayer(keyring: AbstractKeyring, hasher: Function): AbstractFeeDelegatedTransaction | Signs the transaction as a fee payer with private keys in `keyring` and appends the fee payer signature into the transaction object. The `hasher` function will be used when getting the hash of the transaction. If the fee payer address of this transaction instance differs from the address of `keyring`, it throws an exception. |
| signAsFeePayer(keyring: AbstractKeyring, index: int, hasher: Function): AbstractFeeDelegatedTransaction | Signs the transaction as a fee payer with a private key specified by `keyring` and `index. It appends the fee payer signature into the transaction object. The `hasher` function will be used when getting the hash of the transaction. If the fee payer address of this transaction instance differs from the address of `keyring`, it throws an exception. |
| appendFeePayerSignatures(sig: SignatureData): void | Appends a fee payer signature to the transaction instance. |
| appendFeePayerSignatures(sig: List&#60;SignatureData&#62;): void | Appends fee payer signatures to the transaction instance. |
| combineSignedRawTransactions(rlpEncoded: List<String>): String | Collects signatures in RLP-encoded transaction strings in the given array, combines them into this transaction instance, and returns an RLP-encoded transaction string which includes all signatures. If the contents of the transaction are different from this transaction instance, it fails. |
| getRLPEncodingForFeePayerSignature(): String | Returns an RLP-encoded transaction string to make the signature of the fee payer. |

#### AbstractFeeDelegatedWithRatioTransaction

`AbstractFeeDelegatedWithRatioTransaction` is an abstract class that represents transaction types defined in [partial fee delegation transaction](https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation). `AbstractFeeDelegatedWithRatioTransaction` is implemented by extending `AbstractFeeDelegatedTransaction`. All partial fee delegation transaction classes extends `AbstractFeeDelegatedWithRatioTransaction`.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| feeRatio: String | The ratio that constitutes the proportion of the transaction fee the fee payer will be burdened with. The valid range of this ratio is between 1 and 99. The ratio of negatives, 0, or 100 and above are not allowed. |

##### Methods

None

#### LegacyTransaction

`LegacyTransaction` represents a [legacy transaction](https://docs.klaytn.com/klaytn/design/transactions/basic#txtypelegacytransaction). This class is implemented by extending [AbstractTransaction](#abstracttransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The account address that will receive the transferred value or a smart contact address if a legacy transaction executes smart contract. If a legacy transaction deploys a smart contract, this value should be set to empty or null. |
| input: String | Data attached to the transaction. It is used for smart contract deployment/execution. |
| value: String | The amount of KLAY in peb to be transferred. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): LegacyTransaction | Decodes an RLP-encoded string of LegacyTransaction and returns a `LegacyTransaction` instance. It throws an exception if the decoding is failed. |
| appendSignatures(sig: SignatureData): void | Appends signature to the transaction. LegacyTransaction can only have one signature. It throws an exception if the transaction instance has a signature already. |
| appendSignatures(sig: List&#60;SignatureData&#62;): void | Appends signature to the transaction. LegacyTransaction can only have one signature. It throws an exception if multiple signatures are given. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getRLPEncodingForSignature(): String | Returns an RLP-encoded transaction string for making the signature of the sender. Since the method of obtaining the RLP-encoding string for signature of LegacyTransaction is different from other transaction types, getRLPEncodingForSignature should be overridden. It throws an exception if the variables required for encoding are not defined. |

#### ValueTransfer

`ValueTransfer` represents a [value transfer transaction](https://docs.klaytn.com/klaytn/design/transactions/basic#txtypevaluetransfer). This class is implemented by extending [AbstractTransaction](#abstracttransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The account address that will receive the transferred value. |
| value: String | The amount of KLAY in peb to be transferred. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): ValueTransfer | Decodes an RLP-encoded string of ValueTransfer and returns a `ValueTransfer` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### ValueTransferMemo

`ValueTransferMemo` represents a [value transfer memo transaction](https://docs.klaytn.com/klaytn/design/transactions/basic#txtypevaluetransfermemo). This class is implemented by extending [AbstractTransaction](#abstracttransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The account address that will receive the transferred value. |
| value: String | The amount of KLAY in peb to be transferred. |
| input: String | Data attached to the transaction. The message can be passed to this attribute. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): ValueTransferMemo | Decodes an RLP-encoded string of ValueTransferMemo and returns a `ValueTransferMemo` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### AccountUpdate

`AccountUpdate` represents an [account update transaction](https://docs.klaytn.com/klaytn/design/transactions/basic#txtypeaccountupdate). This class is implemented by extending [AbstractTransaction](#abstracttransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| account: Account | An [Account](#account) instance that contains the information needed to update the given account. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): AccountUpdate | Decodes an RLP-encoded string of AccountUpdate and returns a AccountUpdate instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### SmartContractDeploy

`SmartContractDeploy` represents a [smart contract deploy transaction](https://docs.klaytn.com/klaytn/design/transactions/basic#txtypesmartcontractdeploy). This class is implemented by extending [AbstractTransaction](#abstracttransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | An Address to which the smart contract is deployed. Currently, this value cannot be defined by user, so it must be defined with the default value "0x". Specifying the address will be supported in the future. |
| value: String | The amount of KLAY in peb to be transferred. If the value is not defined by user, the value is defined with the default value "0x0". |
| input: String | Data attached to the transaction. It contains the byte code of the smart contract to be deployed and its arguments. |
| humanReadable: String | This must be "false" since human-readable address is not supported yet. If the value is not defined by user, it is defined with the default value "false". |
| codeFormat: String | The code format of the smart contract. The supported value, for now, is "EVM" only. If the value is not defined by user, it is defined with the default value "EVM". This value is converted to a hex string after the assignment (e.g., EVM is converted to 0x0). |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): SmartContractDeploy | Decodes an RLP-encoded string of SmartContractDeploy and returns a `SmartContractDeploy` instance. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### SmartContractExecution

`SmartContractExecution` represents a [smart contract execution transaction](https://docs.klaytn.com/klaytn/design/transactions/basic#txtypesmartcontractexecution). This class is implemented by extending [AbstractTransaction](#abstracttransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The address of the smart contract account to be executed. |
| value: String | The amount of KLAY in peb to be transferred. If the value is not defined by user, the value is defined with the default value "0x0". |
| input: String | Data attached to the transaction, used for transaction execution. The input is an encoded string that indicates a function to call and parameters to be passed. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): SmartContractExecution | Decodes an RLP-encoded string of SmartContractExecution and returns a `SmartContractExecution` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### Cancel

`Cancel` represents a [cancel transaction](https://docs.klaytn.com/klaytn/design/transactions/basic#txtypecancel). This class is implemented by extending [AbstractTransaction](#abstracttransaction).

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): Cancel | Decodes an RLP-encoded string of Cancel and returns a `Cancel` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### ChainDataAnchoring

`ChainDataAnchoring` represents a [chain data anchoring transaction](https://docs.klaytn.com/klaytn/design/transactions/basic#txtypechaindataanchoring). This class is implemented by extending [AbstractTransaction](#abstracttransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| input: String | Data to be anchored. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): ChainDataAnchoring | Decodes an RLP-encoded string of ChainDataAnchoring and returns a `ChainDataAnchoring` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedValueTransfer

`FeeDelegatedValueTransfer` represents a [fee delegated value transfer transaction](https://docs.klaytn.com/klaytn/design/transactions/fee-delegation#txtypefeedelegatedvaluetransfer). This class is implemented by extending [AbstractFeeDelegatedTransaction](#abstractfeedelegatedtransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The account address that will receive the transferred value. |
| value: String | The amount of KLAY in peb to be transferred. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedValueTransfer | Decodes an RLP-encoded string of FeeDelegatedValueTransfer and returns a `FeeDelegatedValueTransfer` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedValueTransferMemo

`FeeDelegatedValueTransferMemo` represents a [fee delegated value transfer memo transaction](https://docs.klaytn.com/klaytn/design/transactions/fee-delegation#txtypefeedelegatedvaluetransfermemo). This class is implemented by extending [AbstractFeeDelegatedTransaction](#abstractfeedelegatedtransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The account address that will receive the transferred value. |
| value: String | The amount of KLAY in peb to be transferred. |
| input: String | Data attached to the transaction. The message can be passed to this attribute. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedValueTransferMemo | Decodes an RLP-encoded string of FeeDelegatedValueTransferMemo and returns a `FeeDelegatedValueTransfer` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): Stirng | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedAccountUpdate

`FeeDelegatedAccountUpdate` represents a [fee delegated account update transaction](https://docs.klaytn.com/klaytn/design/transactions/fee-delegation#txtypefeedelegatedaccountupdate). This class is implemented by extending [AbstractFeeDelegatedTransaction](#abstractfeedelegatedtransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| account: Account | An [Account](#account) instance that contains the information needed to update the given account. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedAccountUpdate | Decodes an RLP-encoded string of FeeDelegatedAccountUpdate and returns a `FeeDelegatedAccountUpdate` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedSmartContractDeploy

`FeeDelegatedSmartContractDeploy` represents a [fee delegated smart contract deploy transaction](https://docs.klaytn.com/klaytn/design/transactions/fee-delegation#txtypefeedelegatedsmartcontractdeploy). This class is implemented by extending [AbstractFeeDelegatedTransaction](#abstractfeedelegatedtransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | An address to which the smart contract is deployed. Currently, this value cannot be defined by user, so it must be defined with the default value "0x". Specifying the address will be supported in the future. |
| value: String | The amount of KLAY in peb to be transferred. If the value is not defined by user, the value is defined with the default value "0x0". |
| input: String | Data attached to the transaction. It contains the byte code of the smart contract to be deployed and its arguments. |
| humanReadable: String | This must be "false" since human-readable address is not supported yet. If the value is not defined by user, it is defined with the default value "false". |
| codeFormat: String | The code format of the smart contract. The supported value, for now, is "EVM" only. If it is not defined by user, it is defined with the default value "EVM". This value is converted to a hex string after the assignment(e.g., EVM is converted to 0x0). |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedSmartContractDeploy | Decodes an RLP-encoded string of FeeDelegatedSmartContractDeploy and returns a `FeeDelegatedSmartContractDeploy` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedSmartContractExecution

`FeeDelegatedSmartContractExecution` represents a [fee delegated smart contract execution transaction](https://docs.klaytn.com/klaytn/design/transactions/fee-delegation#txtypefeedelegatedsmartcontractexecution). This class is implemented by extending [AbstractFeeDelegatedTransaction](#abstractfeedelegatedtransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The address of the smart contract account to be executed. |
| value: String | The amount of KLAY in peb to be transferred. If the value is not defined by user, the value is defined with the default value "0x0". |
| input: String | Data attached to the transaction, used for transaction execution. The input is an encoded string that indicates a function to call and parameters to be passed. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedSmartContractExecution | Decodes an RLP-encoded string of FeeDelegatedSmartContractExecution and returns a `FeeDelegatedSmartContractExecution` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedCancel

`FeeDelegatedCancel` represents a [fee delegated cancel transaction](https://docs.klaytn.com/klaytn/design/transactions/fee-delegation#txtypefeedelegatedcancel). This class is implemented by extending [AbstractFeeDelegatedTransaction](#abstractfeedelegatedtransaction).

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedCancel | Decodes an RLP-encoded string of FeeDelegatedCancel and returns a `FeeDelegatedCancel` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedChainDataAnchoring

`FeeDelegatedChainDataAnchoring` represents a [fee delegated chain data anchoring transaction](https://docs.klaytn.com/klaytn/design/transactions/fee-delegation#txtypefeedelegatedchaindataanchoring). This class is implemented by extending [AbstractFeeDelegatedTransaction](#abstractfeedelegatedtransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| input: String | Data to be anchored. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedChainDataAnchoring | Decodes an RLP-encoded string of FeeDelegatedChainDataAnchoring and returns a `FeeDelegatedChainDataAnchoring` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedValueTransferWithRatio

`FeeDelegatedValueTransferWithRatio` represents a [fee delegated value transfer with ratio transaction](https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation#txtypefeedelegatedvaluetransferwithratio). This class is implemented by extending [AbstractFeeDelegatedWithRatioTransaction](#abstractfeedelegatedwithratiotransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The account address that will receive the transferred value. |
| value: String | The amount of KLAY in peb to be transferred. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedValueTransferWithRatio | Decodes an RLP-encoded string of FeeDelegatedValueTransferWithRatio and returns a `FeeDelegatedValueTransferWithRatio` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedValueTransferMemoWithRatio

`FeeDelegatedValueTransferMemoWithRatio` represents a [fee delegated value transfer memo with ratio transaction](https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation#txtypefeedelegatedvaluetransfermemowithratio). This class is implemented by extending [AbstractFeeDelegatedWithRatioTransaction](#abstractfeedelegatedwithratiotransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The account address that will receive the transferred value. |
| value: String | The amount of KLAY in peb to be transferred. |
| input: String | Data attached to the transaction. The message can be passed to this attribute. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedValueTransferMemoWithRatio | Decodes an RLP-encoded string of FeeDelegatedValueTransferMemoWithRatio and returns a `FeeDelegatedValueTransferMemoWithRatio` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): Stirng | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedAccountUpdateWithRatio

`FeeDelegatedAccountUpdateWithRatio` represents a [fee delegated account update with ratio transaction](https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation#txtypefeedelegatedaccountupdatewithratio). This class is implemented by extending [AbstractFeeDelegatedWithRatioTransaction](#abstractfeedelegatedwithratiotransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| account: Account | An [Account](#account) instance that contains the information needed to update the given account. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedAccountUpdateWithRatio | Decodes an RLP-encoded string of FeeDelegatedAccountUpdateWithRatio and returns a `FeeDelegatedAccountUpdateWithRatio` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedSmartContractDeployWithRatio

`FeeDelegatedSmartContractDeployWithRatio` represents a [fee delegated smart contract deploy with ratio transaction](https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation#txtypefeedelegatedsmartcontractdeploywithratio). This class is implemented by extending [AbstractFeeDelegatedWithRatioTransaction](#abstractfeedelegatedwithratiotransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | An address to which the smart contract is deployed. Currently, this value cannot be defined by user, so it must be defined with the default value "0x". Specifying the address will be supported in the future. |
| value: String | The amount of KLAY in peb to be transferred. If the value is not defined by user, the value must be defined with the default value "0x0". |
| input: String | Data attached to the transaction. It contains the byte code of the smart contract to be deployed and its arguments. |
| humanReadable: String | This must be "false" since human-readable address is not supported yet. If the value is not defined by user, it is defined with the default value "false". |
| codeFormat: String | The code format of smart contract code. The supported value, for now, is "EVM" only. If it is not defined by user, it is defined with the default value "EVM". This value is converted to a hex string after the assignment(e.g., EVM is converted to 0x0). |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedSmartContractDeployWithRatio | Decodes an RLP-encoded string of FeeDelegatedSmartContractDeployWithRatio and returns a `FeeDelegatedSmartContractDeployWithRatio` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedSmartContractExecutionWithRatio

`FeeDelegatedSmartContractExecutionWithRatio` represents a [fee delegated smart contract execution with ratio transaction](https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation#txtypefeedelegatedsmartcontractexecutionwithratio). This class is implemented by extending [AbstractFeeDelegatedWithRatioTransaction](#abstractfeedelegatedwithratiotransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| to: String | The address of the smart contract account to be executed. |
| value: String | The amount of KLAY in peb to be transferred. If the value is not defined by user, it is defined with the default value "0x0". |
| input: String | Data attached to the transaction, used for transaction execution. The input is an encoded string that indicates a function to call and parameters to be passed. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedSmartContractExecutionWithRatio | Decodes an RLP-encoded string of FeeDelegatedSmartContractExecutionWithRatio and returns a `FeeDelegatedSmartContractExecutionWithRatio` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedCancelWithRatio

`FeeDelegatedCancelWithRatio` represents a [fee delegated cancel with ratio transaction](https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation#txtypefeedelegatedcancelwithratio). This class is implemented by extending [AbstractFeeDelegatedWithRatioTransaction](#abstractfeedelegatedwithratiotransaction).

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedCancelWithRatio | Decodes an RLP-encoded string of FeeDelegatedCancelWithRatio and returns a `FeeDelegatedCancelWithRatio` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transation instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### FeeDelegatedChainDataAnchoringWithRatio

`FeeDelegatedChainDataAnchoringWithRatio` represents a [fee delegated chain data anchoring with ratio transaction](https://docs.klaytn.com/klaytn/design/transactions/partial-fee-delegation#txtypefeedelegatedchaindataanchoringwithratio). This class is implemented by extending [AbstractFeeDelegatedWithRatioTransaction](#abstractfeedelegatedwithratiotransaction).

##### Variables

| Variable | Description |
| ----------- | ----------- |
| input: String | Data to be anchored. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): FeeDelegatedChainDataAnchoringWithRatio | Decodes an RLP-encoded string of FeeDelegatedChainDataAnchoringWithRatio and returns a `FeeDelegatedChainDataAnchoringWithRatio` instance. It throws an exception if the decoding is failed. |
| getRLPEncoding(): String | Returns an RLP-encoded string of the transaction instance. It throws an exception if the variables required for encoding are not defined. |
| getCommonRLPEncodingForSignature(): String | Encodes the values needed to sign the transaction and returns the RLP-encoded string. It throws an exception if the variables required for encoding are not defined. |

#### TransactionDecoder

`TransactionDecoder` provides the function to decode an RLP-encoded string of a transaction class.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| decode(rlpEncoded: String): AbstractTransaction | Decodes an RLP-encoded transaction string and returns a transaction instance. It throws an exception if the decoding is failed. |

#### TransactionHasher

`TransactionHasher` provides the functions to calculate the hash of a transaction for signing.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| getHashForSignature(transaction: AbstractTransaction): String | Returns the hash of the transaction for the sender to sign. |
| getHashForFeePayerSignature(transaction: AbstractFeeDelegatedTransaction): String | Returns the hash of the transaction for the fee payer to sign. |

### RPC Layer

The `RPC` layer provides the functions to use the Node APIs. The `RPC` is a class that manages the Node API for each namespace. Node APIs currently provided by Caver are [klay] and [net].

![0811RPC](https://user-images.githubusercontent.com/32922423/89860609-d6220d80-dbde-11ea-85f6-ea3fc6f47991.png)

`Klay` is a class that provides [klay namespace of the Node API]. `Net` is a class that provides [net namespace of the Node API]. The result value received from a Klaytn Node is returned to the user. For more information about each API and the returned result, refer to [JSON-RPC APIs].

#### Klay

`Klay` provides JSON-RPC call with "klay" namespace.

##### Variables

None

##### Methods

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
| isContractAccount(address: String): Boolean | Call `klay_isContractAccount` JSON-RPC. |
| isContractAccount(address: String, blockNumber: int): Boolean | Call `klay_isContractAccount` JSON-RPC. |
| isContractAccount(address: String, blockTag: String): Boolean | Call `klay_isContractAccount` JSON-RPC. |
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

`Net` provides JSON-RPC call with "net" namespace.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| getNetworkID(): String | Call `net_networkID` JSON-RPC. |
| isListening(): Boolean | Call `net_listening` JSON-RPC. |
| getPeerCount(): String | Call `net_peerCount` JSON-RPC. |
| getPeerCountByType(): Object | Call `net_peerCountByType` JSON-RPC. |

### Contract, ABI, KCT Layer

The `Contract` layer provides the functions to interact with smart contracts on Klaytn. This Contract layer uses the function of the `ABI` layer that provides the functions to encode and decode parameters with the ABI (Application Binary Interface). `KCT` is a layer that provides the functions to interact with KCT token contracts (i.e., [KIP-7] or [KIP-17]) on Klaytn.

![0811Contract](https://user-images.githubusercontent.com/32922423/89860622-de7a4880-dbde-11ea-9986-3af7ae595150.png)

The `Contract` class makes it easy to interact with smart contracts based on ABI. If you have the byte code and constructor parameters, you can use the `Contract` instance to deploy the smart contract to Klaytn. The class can process the ABI so that the user can easily call the smart contract function through a member variable called `methods`.

The `ABI` class provides functions to encode and decode parameters. The `Contract` class encodes and decodes the parameters required for smart contract deployment and execution using the functions provided by the ABI. To create a transaction to deploy or execute a smart contract, the required data can be filled with `ABI`.

The `KIP7` class provides the functions to interact with [KIP-7] token contracts on Klaytn. This class allows users to easily
deploy and execute [KIP-7] token contracts on Klaytn. `KIP7` maps all functions defined in [KIP-7] and provides them as class methods.

The `KIP17` class provides the functions to interact with [KIP-17] token contracts on Klaytn. This class allows users to easily
deploy and execute [KIP-17] token contracts on Klaytn. `KIP17` maps all functions defined in [KIP-17] and provides them as class methods.

#### Contract

`Contract` is a class that allows users to easily interact with smart contracts on Klaytn. It can deploy a smart contract to Klaytn or execute a smart contract deployed on Klaytn.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| address: String | The address of the smart contract to call. If the smart contract has already been deployed to Klaytn, user can specify the address of the smart contract to be called. This value is set after the contract deployment is successfully performed. |
| abi: List&#60;Object&#62; | The abi of the smart contract to interact with. |
| methods: Map&#60;String:[ContractMethod](#contractmethod)&#62; | The methods of the smart contract. When a contract receives an abi from the user, it parses the abi, makes functions that can be called into `ContractMethod`, and stores them into this variable. |
| events: Map&#60;String:[ContractEvent](#contractevent)&#62; | The events of the smart contract. When a contract receives an abi from the user, it parses the abi, makes events that can be fired into `ContractEvent`, and stores them into this variable. |
| defaultSendOptions: SendOptions | An object that contains information to be used as default values when a user sends a transaction that changes the state of a smart contract. The values (`from`, `gas`, and `value`) can be optionally defined in SendOptions. When a user calls a method to send a transaction, the user can optionally define sendOptions. If the user defines sendOptions separately when calling the function, the parameter in the function call has higher priority. The conflicting attributes in this variable will be ignored in that case. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| deploy(deployParam: [ContractDeployParams](#contractdeployparams), options: SendOptions): Contract | Deploys the contract to Klaytn. |
| once(event: String, callback: Function): void | Subscribes to an event and unsubscribes immediately after the first event or error. |
| once(event: String, options: Object, callback: Function): void | Subscribes to an event and unsubscribes immediately after the first event or error. The options object should define `filter` or `topics`. |
| getPastEvent(event: String): List&#60;Object&#62; | Gets past events for this contract. |
| getPastEvent(event: String, options: Object): List&#60;Object&#62; | Gets past events for this contract. The options object can define the filter options needed when calling [klay_logs]. See [klay_logs] for more details about options. |
| getPastEvent(event: String, callback: Function): List&#60;Object&#62; | Gets past events for this contract. |
| getPastEvent(event: String, options: Object, callback: Function): List&#60;Object&#62; | Gets past events for this contract. The options object can define the filter options needed when calling [klay_logs]. See [klay_logs] for more details about options. |

#### ContractMethod

`ContractMethod` is a class that contains abi information of a smart contract function.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| name: String | The name of the function in a smart contract. |
| inputs: List&#60;[ContractIOType](#contractiotype)&#62; | The input values of the function. In the list, each parameter of the function is defined as ContractIOType. When the `call` or `send` function is called, this is used to encode the parameter to create the input field of a transaction. |
| outputs: List&#60;[ContractIOType](#contractiotype)&#62; | The output values of the function. This is used to decode the value returned as the result of executing the function. |
| signature: String | The [function signature](https://docs.klaytn.com/bapp/sdk/caver-js/api-references/caver.contract#cf-function-signature-function-selector) (function selector). The first four bytes of the input data for specifying the function to be called (or executed). It is the first (left, high-order in big-endian) four bytes of the Keccak-256 (SHA-3) hash of the signature of the function. |
| nextMethods: List&#60;ContractMethod&#62; | nextMethods stores functions with the same name implemented in a smart contract. If the parameter passed by the user is different from the input of this contractMethod, it traverses the contractMethods defined in nextMethods to find the contractMethod to be called. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| call(argumetns: List&#60;any&#62;, callObject: Object): any | Calls a "constant" method and execute its smart contract method in the Klaytn Virtual Machine without sending any transaction. See [klay_call] for more details about callObject. |
| send(arguments: List&#60;any&#62;, options: SendOptions): Object | Sends a transaction to the smart contract and executes its method. This can alter the smart contract state. It sends a transaction using the value defined in defaultSendOptions of the Contract. It throws an exception if the value required for transaction (i.e `from` or `gas`) is not defined in defaultSendOptions. |
| send(arguments: List&#60;any&#62;): Object | Send a transaction to the smart contract and execute its method. This can alter the smart contract state. |
| encodeABI(arguments: List&#60;any&#62;): String | Generates data to be filled in the `input` field of a transaction. This can be used to send a transaction, call a method, or pass it into another smart contract method as arguments. |
| estimateGas(arguments: List&#60;any&#62;, callObject: Object): String | Estimates the gas that a method execution will take when executed in the Klaytn Virtual Machine. See [klay_call] for more details about callObject. |

#### ContractEvent

`ContractEvent` is a class that contains abi information of a smart contract event.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| name: String | The name of the event in the smart contract. |
| inputs: List&#60;[ContractIOType](#contractiotype)&#62; | The input values of the event. In the list, each input of the event is defined as ContractIOType. This value is used to convert the parameter to a topic. |
| signature: String | The event signature which is the sha3 hash of the event name including input parameter types. |

##### Methods

None

#### ContractIOType

`ContractIOType` is a class used when defining the input and output of the smart contract.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| name: String | The name of the value. |
| type: String | The type of the value. |
| indexed: Boolean | Whether indexed or not, the input values of the contract event are separately defined as indexed. If indexed is not separately used, there is no need to define this. |

##### Methods

None

#### SendOptions

`SendOptions` is a class that defines values required when sending a transaction. When executing a method that triggers a transaction, the user can use it to define from, gas or value.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| from: String | The address of the sender. |
| gas: String | The maximum amount of transaction fee that the transaction is allowed to use. |
| value: String | The value in peb to be transferred to the address of the smart contract by this transaction. |

##### Methods

None

#### ContractDeployParams

`ContractDeployParams` is a class that defines the byte code and constructor parameters required when deploying a smart contract.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| byteCode: String | The byte code of the contract. |
| args: List&#60;any&#62; | The arguments that get passed to the constructor on deployment. |

##### Methods

None

#### ABI

`ABI` provides the functions to encode/decode parameters with ABI.

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| encodeFunctionSignature(method: ContractMethod): String | Encodes the function signature to its ABI signature, which are the first 4 bytes of the sha3 hash of the function name with its parameter types. |
| encodeFunctionSignature(functionString: String): String | Encodes the function signature to its ABI signature, which are the first 4 bytes of the sha3 hash of the function name with its parameter types. |
| encodeEventSignature(event: ContractEvent): String | Encodes the event signature to its ABI signature, which is the sha3 hash of the event name with its parameter types. |
| encodeEventSignature(eventString: String): String | Encodes the event signature to its ABI signature, which is the sha3 hash of the event name with its parameter types. |
| encodeParameter(type: String, param: any): String | Encodes a parameter based on its type to its ABI representation. It throws an exception if the param is invalid. |
| encodeParameters(types: List&#60;String&#62;, params: List&#60;any&#62;): String | Encodes parameters based on its type to its ABI representation. It throws an exception if the params are invalid. |
| encodeFunctionCall(method: ContractMethod, params: List&#60;any&#62;): String | Encodes a function call using its JSON interface object and given parameters. It throws an exception if the params are invalid. |
| decodeParameter(type: String, encoded: String): String | Decodes an ABI-encoded parameter. It throws an exception if the decoding is failed. |
| decodeParameters(types: List&#60;String&#62;, encoded: String): List&#60;String&#62; | Decodes ABI-encoded parameters. It throws an exception if the decoding is failed. |
| decodeParameters(method: ContractMethod, encoded: String): List&#60;String&#62; | Decodes ABI-encoded parameters. It throws an exception if the decoding is failed. |
| decodeLog(inputs: List&#60;ContractIOType&#62;, data: String, topics: List&#60;String&#62;): JSONObject | Decodes ABI-encoded log data and indexed topic data. It throws an exception if the decoding is failed. |
| encodeContractDeploy(constructor: ContractMethod, byteCode: String, params: List&#60;any&#62;): String | Encodes smart contract bytecode with the arguments of the constructor for smart contract deployment. |

#### KIP7

`KIP7` is a class to easily interact with Klaytn's KIP-7 token contract. This is implemented by extending [Contract](#contract).

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| deploy(tokenInfo: [KIP7DeployParams](#kip7deployparams), deployer: String): KIP7 | Deploys the KIP-7 token contract to the Klaytn. |
| clone(): KIP7 | Clones the current KIP7 instance. |
| clone(tokenAddress: address): KIP7 | Clones the current KIP7 instance and sets the address of the new instance to `tokenAddress` . |
| supportInterface(interfaceid: String): Boolean | Returns true if this contract implements the interface defined by `interfaceId`. |
| name(): String | Returns the name of the token. |
| symbol(): String | Returns the symbol of the token. |
| decimals(): int | Returns the number of decimal places the token uses. |
| totalSupply(): BigInteger | Returns the total token supply. |
| balanceOf(account: String): BigInteger | Returns the balance of the given account address. |
| allowance(owner: String, spender: String): BigInteger | Returns the amount of tokens that `spender` is allowed to withdraw tokens of `owner`. |
| isMinter(account: String): Boolean | Returns true if the given account is a minter who can issue new KIP7 tokens. |
| isPauser(account: String): Boolean | Returns true if the given account is a pauser who can suspend transferring tokens. |
| paused(): Boolean | Returns true if the contract is paused, and false otherwise. |
| approve(spender: String, amount: BigInteger): Object | Sets the amount of the tokens of the token owner to be spent by the spender. |
| approve(spender: String, amount: BigInteger, sendParam: SendOptions): Object | Sets the amount of the tokens of the token owner to be spent by the spender. The transaction is formed based on `sendParam`. |
| transfer(recipient: String, amount: BigInteger): Object | Transfers the given amount of the token from the token owner's balance to the recipient. |
| transfer(recipient: String, amount: BigInteger, sendParam: SendOptions): Object | Transfers the given amount of the token from the token owner's balance to the recipient. The transaction is formed based on `sendParam`. |
| transferFrom(sender: String, recipient: String, amount: BigInteger): Object | Transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| transferFrom(sender: String, recipient: String, amount: BigInteger, sendParam: SendOptions): Object | Transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. The transaction is formed based on `sendParam`. |
| safeTransfer(recipient: String, amount: BigInteger): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. |
| safeTransfer(recipient: String, amount: BigInteger, sendParam: SendOptions): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. The transaction is formed based on `sendParam`. |
| safeTransfer(recipient: String, amount: BigInteger, data: String): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient with additional data. |
| safeTransfer(recipient: String, amount: BigInteger, data: String, sendParam: SendOptions): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient with additional data. The transaction is formed based on `sendParam`. |
| safeTransferFrom(sender: String, recipient: String, amount: BigInteger): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| safeTransferFrom(sender: String, recipient: String, amount: BigInteger, sendParam: SendOptions): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. The transaction is formed based on `sendParam`. |
| safeTransferFrom(sender: String, recipient: String, amount: BigInteger, data: String): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient with additional data. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. |
| safeTransferFrom(sender: String, recipient: String, amount: BigInteger, data: String, sendParam: SendOptions): Object | Safely transfers the given amount of the token from the token owner's balance to the recipient with additional data. The address who was approved to send the token owner's tokens is expected to execute this token transferring transaction. The transaction is formed based on `sendParam`. |
| mint(account: String, amount: BigInteger): Object | Creates the amount of tokens and issues them to the account, increasing the total supply of tokens. |
| mint(account: String, amount: BigInteger, sendParam: SendOptions): Object | Creates the amount of tokens and issues them to the account, increasing the total supply of tokens. The transaction is formed based on `sendParam`. |
| addMinter(account: String): Object | Adds an account as a minter, who are permitted to mint tokens. |
| addMinter(account: String, sendParam: SendOptions): Object | Adds an account as a minter, who are permitted to mint tokens. The transaction is formed based on `sendParam`. |
| renounceMinter(): Object | Renounces the right to mint tokens. Only a minter can renounce the minting right. |
| renounceMinter(sendParam: SendOptions): Object | Renounces the right to mint tokens. Only a minter can renounce the minting right. The transaction is formed based on `sendParam`. |
| burn(amount: BigInteger): Object | Destroys the amount of tokens in the sender's balance. |
| burn(amount: BigInteger, sendParam: SendOptions): Object | Destroys the amount of tokens in the sender's balance. The transaction is formed based on `sendParam`. |
| burnFrom(account: String, amount: BigInteger): Object | Destroys the given number of tokens from `account`. The address who was approved to use the token owner's tokens is expected to execute this token burning transaction. |
| burnFrom(account: String, amount: BigInteger, sendParam: SendOptions): Object | Destroys the given number of tokens from `account`. The address who was approved to use the token owner's tokens is expected to execute this token burning transaction. The transaction is formed based on `sendParam`. |
| addPauser(account: String): Object | Adds an account as a pauser that has the right to suspend the contract. |
| addPauser(account: String, sendParam: SendOptions): Object | Adds an account as a pauser that has the right to suspend the contract. The transaction is formed based on `sendParam`. |
| pause(): Object | Suspends functions related to sending tokens. |
| pause(sendParam: SendOptions): Object | Suspends functions related to sending tokens. The transaction is formed based on `sendParam`. |
| unpause(): Object | Resumes the paused contract. |
| unpause(sendParam: SendOptions): Object | Resumes the paused contract. The transaction is formed based on `sendParam`. |
| renouncePauser(): Object | Renounces the right to pause the contract. Only a pauser address can renounce the pausing right. |
| renouncePauser(sendParam: SendOptions): Object | Renounces the right to pause the contract. Only a pauser address can renounce the pausing right. The transaction is formed based on `sendParam`. |

#### KIP7DeployParams

`KIP7DeployParams` is a class that defines the token informations required when deploying a KIP-7 token contract.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| name: String | The name of the token. |
| symbol: String | The symbol of the token. |
| decimals: int | The number of decimal places the token uses. |
| initialSupply: BigInteger | The total amount of token to be supplied initially. |

##### Methods

None

#### KIP17

`KIP17` is a class to easily interact with Klaytn's KIP-17 token contract. This is implemented by extending [Contract](#contract).

##### Variables

None

##### Methods

| Method | Description |
| ----------- | ----------- |
| deploy(tokenInfo: KIP17DeployParams, deployer: String): KIP17 | Deploys the KIP-17 token contract to Klaytn. |
| clone(): KIP17 | Clones the current KIP17 instance. |
| clone(tokenAddress: String): KIP17 | Clones the current KIP17 instance and sets address of the new contract instance to `tokenAddress` . |
| supportInterface(interfaceId: String): Boolean | Returns true if this contract implements the interface defined by `interfaceId`. |
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
| paused(): Boolean | Returns true if the contract is paused. It returns false otherwise. |
| isPauser(account: String): Boolean | Returns true if the given account is a pauser who can suspend transferring tokens. |
| approve(to: String, tokenId: BigInteger): Object | Approves another address to transfer a token of the given token id. |
| approve(to: String, tokenId: BigInteger, sendParam: SendOptions): Object | Approves another address to transfer a token of the given token id. The transaction is formed based on `sendParam`. |
| setApprovalForAll(to: String, approved: Boolean): Object | Approves or disallow the given operator to transfer all tokens of the owner based on `approved`. |
| setApprovalForAll(to: String, approved: Boolean, sendParam: SendOptions): Object | Approves or disallow the given operator to transfer all tokens of the owner based on `approved`. The transaction is formed based on `sendParam`. |
| transferFrom(from: String, to: String, tokenId: BigInteger): Object | Transfers the token specified by `tokenId` from the the owner to `to`. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. |
| transferFrom(from: String, to: String, tokenId: BigInteger, sendParam: SendOptions): Object | Transfers the token specified by `tokenId` from the the owner to `to`. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. The transaction is formed based on `sendParam`. |
| safeTransferFrom(from: String, to: String, tokenId: BigInteger): Object | Safely transfers the token specified by `tokenId` from the owner to `to`. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. |
| safeTransferFrom(from: String, to: String, tokenId: BigInteger, sendParam: SendOptions): Object | Safely transfers the token specified by `tokenId` from the owner to `to`. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. The transaction is formed based on `sendParam`. |
| safeTransferFrom(from: String, to: String, tokenId: BigInteger, data: String): Object | Safely transfers the token specified by `tokenId` from the owner to `to` with additional `data`. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. |
| safeTransferFrom(from: String, to: String, tokenId: BigInteger, data: String, sendParam: SendOptions): Object | Safely transfers the token specified by `tokenId` from the owner to `to` with additional `data`. The address who was approved to send the token owner's token (the operator) or the token owner itself is expected to execute this token transferring transaction. The transaction is formed based on `sendParam`. |
| addMinter(account: String): Object | Adds an account as a minter, who are permitted to mint tokens. |
| addMinter(account: String, sendParam: SendOptions): Object | Adds an account as a minter, who are permitted to mint tokens. The transaction is formed based on `sendParam`. |
| renounceMinter(): Object | Renounces the right to mint tokens. Only a minter address can renounce the minting right. |
| renounceMinter(sendParam: SendOptions): Object | Renounces the right to mint tokens. Only a minter address can renounce the minting right. The transaction is formed based on `sendParam`. |
| mint(to: String, tokenId: BigInteger): Object | Creates a token and assigns it to the given account `to`. This method increases the total supply of the contract. |
| mint(to: String, tokenId: BigInteger, sendParam: SendOptions): Object | Creates a token and assigns it to the given account `to`. This method increases the total supply of the contract. The transaction is formed based on `sendParam`. |
| mintWithTokenURI(to: String, tokenId: BigInteger, toeknURI: String): Object | Creates a token with the given uri and assigns it to the given account `to`. This method increases the total supply of the contract. |
| mintWithTokenURI(to: String, tokenId: BigInteger, toeknURI: String, sendParam: SendOptions): Object | jCreates a token with the given uri and assigns it to the given account `to`. This method increases the total supply of the contract. The transaction is formed based on `sendParam`. |
| burn(tokenId: BigInteger): Object | Destroys the token of the given token id. |
| burn(tokenId: BigInteger, sendParam: SendOptions): Object | Destroys the token of the given token id. The transaction is formed based on `sendParam`. |
| pause(): Object | Suspends functions related to sending tokens. |
| pause(sendParam: SendOptions): Object | Suspends functions related to sending tokens. The transaction is formed based on `sendParam`. |
| unpause(): Object | Resumes the paused contract. |
| unpause(sendParam: SendOptions): Object | Resumes the paused contract. The transaction is formed based on `sendParam`. |
| addPauser(account: String): Object | Adds an account as a pauser that has the right to suspend the contract. |
| addPauser(account: String, sendParam: SendOptions): Object | Adds an account as a pauser that has the right to suspend the contract. The transaction is formed based on `sendParam`. |
| renouncePauser(): Object | Renounces the right to pause the contract. |
| renouncePauser(sendParam: SendOptions): Object | Renounces the right to pause the contract. The transaction is formed based on `sendParam`. |

#### KIP17DeployParams

`KIP17DeployParams` is a class that defines the token informations required when deploying a KIP-17 token contract.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| name: String | The name of the token. |
| symbol: String | The symbol of the token. |

##### Methods

None

### Utils Layer

The Utils layer provides utility functions.

![0811Utils](https://user-images.githubusercontent.com/32922423/89860605-d4f0e080-dbde-11ea-86e3-8d77d66ebb4a.png)

The Utils class provides basic utility functions required when using Caver, and it also provides converting functions based on `KlayUnit`.

#### Utils

`Utils` provides the utility functions.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| klayUnit: KlayUnit | Unit of KLAY used in Klaytn. |

##### Methods

| Method | Description |
| ----------- | ----------- |
| isAddress(address: String): Boolean | Checks if a given string is a valid Klaytn address. It will also check the checksum if the address has upper and lowercase letters. |
| isValidPrivateKey(key: String): Boolean | Returns true if the given string is a valid private key. Otherwise, it returns false. |
| isKlaytnWalletKey(key: String): Boolean | Returns true if the given string is a valid KlaytnWalletKey. Otherwise, it returns false. |
| isValidPublicKey(key: String): Boolean | Returns true if the given string is a valid public key. Otherwise, it returns false. |
| compressPublicKey(key: String): String | Compresses the uncompressed public key and returns the compressed public key. |
| decompressPublicKey(key: String): String | Decompresses the compressed public key and returns the uncompressed public key. |
| hashMessage(message: String): String | Hashes the given lmessage with the Klaytn-specific prefix: `keccak256("\x19Klaytn Signed Message:\n" + len(message) + message))` |
| parseKlaytnWalletKey(key: String): String[] | Parses the givein KlaytnWalletKey string to an array which includes "private key", "type", "address". |
| isHex(str: String): boolean | Checks if a given string is a hex string. |
| isHexStrict(str: String): boolean | Checks if a given string is a hex string. Difference to `isHex` is that it expects the string to be prefixed with 0x. |
| addHexPrefix(str: String): String | Returns a 0x-prefixed hex string. If the input is already 0x-prefixed or a non-hex string, the input value is returned as-is. |
| stripHexPrefix(str: String): String | Returns the result with 0x prefix stripped from input. |
| convertToPeb(num: String, unit: String): String | Converts any KLAY value into peb. |
| convertToPeb(num: String, unit: KlayUnit): String | Converts any KLAY value into peb. |
| convertFromPeb(num: String, unit: String): String | Converts any KLAY value from peb. |
| convertFromPeb(num: String, unit: KlayUnit): String | Converts any KLAY value from peb. |
| recover(message: String, signature: KlaySignatureData): String | Recovers the Klaytn address that was used to sign the given data. |
| recover(message: String, signature: KlaySignatureData, preFixed: Boolean): String | Recovers the Klaytn address that was used to sign the given data. |

#### KlayUnit

`KlayUnit` is defined as the [unit used in Klaytn](https://docs.klaytn.com/klaytn/design/klaytn-native-coin-klay#units-of-klay) as an enumerated type. Each unit defines the unit's `name` and `pebFactor`. `pebFactor` is used when converting the value to peb.

##### Variables

| Variable | Description |
| ----------- | ----------- |
| peb: Object | unit: 'peb', pebFactor: 0 |
| kpeb: Object | unit: 'kpeb', pebFactor: 3 |
| Mpeb: Object | unit: 'Mpeb', pebFactor: 6 |
| Gpeb: Object | unit: 'Gpeb', pebFactor: 9 |
| ston: Object | unit: 'ston', pebFactor: 9 |
| uKLAY: Object | unit: 'uKLAY', pebFactor: 12 |
| mKLAY: Object | unit: 'mKLAY', pebFactor: 15 |
| KLAY: Object | unit: 'KLAY', pebFactor: 18 |
| kKLAY: Object | unit: 'kKLAY', pebFactor: 21 |
| MKLAY: Object | unit: 'MKLAY', pebFactor: 24 |
| GKLAY: Object | unit: 'GKLAY', pebFactor: 27 |
| TKLAY: Object | unit: 'TKLAY', pebFactor: 30 |

### Example Usage of the Common Architecture

In this chapter, the pseudocode for sending a transaction using the SDK that implements the common architecture is explained.

```
input: keystore.json, password, from, to, value, gas
output: receipt of value transfer transaction

// Read keystore json file and decrypt keystore
keystore <- readFile('./keystore.json')
keyring <- decryptKeystore(keystore, password)

// Add the keyring to the in-memory wallet
addToTheWallet(keyring)

// Create a value transfer transaction
vt <- createValueTransferTransaction(from, to, value, gas)

// Sign the transaction
signed <- sign(from, vt)

// Send the transaction to Klaytn
receipt <- sendRawTransaction(signed)
print receipt
```

## Rationale

While designing the common architecture, we tried to use the concept used in Klaytn as much as possible.

## Backwards Compatibility

The backward compatibility is preserved. That is, previous implementation using Klaytn SDKs will work without any changes.

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
[klay namespace of the node api]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay
[net]: https://docs.klaytn.com/bapp/json-rpc/api-references/network
[net namespace of the node api]: https://docs.klaytn.com/bapp/json-rpc/api-references/network
[json-rpc apis]: https://docs.klaytn.com/bapp/json-rpc/api-references
[klay_logs]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay/filter#klay_getlogs
[klay_call]: https://docs.klaytn.com/bapp/json-rpc/api-references/klay/transaction#klay_call
