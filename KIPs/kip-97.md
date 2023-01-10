---
kip: 97
title: Signed Data Standard
author: TaeRim Lee <95decode@gmail.com>
discussions-to: https://forum.klaytn.foundation/t/kip/6359
status: Draft
type: Standards Track
category : Interface
created: 2023-01-10
---

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->
This is to standardize message signing methods different from those of Ethereum.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
This standard proposes a specification about how to handle signed data in Klaytn.

## Motivation
<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->
Several multisignature wallet implementations have been created which accepts `presigned` transactions. A `presigned` transaction is a chunk of binary `signed_data`, along with signature (`r`, `s` and `v`). The interpretation of the `signed_data` has not been specified and ethereum solved this by EIP-191 standard. Additionally, the signature result is different in using metamask and kaikas because Klaytn does not have a standard.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->
This document is heavily derived from [EIP-191](https://eips.ethereum.org/EIPS/eip-191) written by Martin Holst Swende and Nick Johnson.

We propose the following format for `signed_data`

```
0x19 <1 byte version> <version specific data> <data to sign>.
```

The initial `0x19` byte is intended to ensure that the `signed_data` is not valid RLP.

> For a single byte whose value is in the [0x00, 0x7f] range, that byte is its own RLP encoding.

That means that any `signed_data` cannot be one RLP-structure, but a 1-byte `RLP` payload followed by something else. Thus, any `signed_data` can never be an Klaytn transaction.

The following format is prepended before hashing in personal_sign:

```
"\x19Klaytn Signed Message:\n" + len(message).
```

Using `0x19` thus makes it possible to extend the scheme by defining a version `0x4b` (`K`) to handle these kinds of signatures.

### Registry of version bytes

| Version byte | KIP            | Description
| ------------ | -------------- | -----------
|    `0x4b`    | [97][kip-97]   | `personal_sign` messages

#### Version `0x4b` (K)

```
0x19 <0x4b (K)> <laytn Signed Message:\n" + len(message)> <data to sign>
```

The version `0x4b` (K) has `<laytn Signed Message:\n" + len(message)>` for the version-specific data. The data to sign can be any arbitrary data.

> NB: The `K` in `Klaytn Signed Message` refers to the version byte 0x4b. The character `K` is `0x4b` in hexadecimal which makes the remainder, `laytn Signed Message:\n + len(message)`, the version-specific data.

[kip-97]: ./kip-97.md

### Specification of the caver.js API

```JavaScript
caver.klay.accounts.sign('Some data', '0x{private key}');
```

### Returns

```shell
{
    message: 'Some data',
    messageHash: '0x8ed2036502ed7f485b81feaec1c581d236a8b711e55a24077724879c8a263c2a',
    v: '0x1b',
    r: '0x4a57bcff1637346a4323a67acd7a478514d9f00576f42942d50a5ca0e4b0342b',
    s: '0x5914e19a8ebc10ce1450b00a3b9c1bf0ce01909bca3ffdead1aa3a791a97b5ac',
    signature: '0x4a57bcff1637346a4323a67acd7a478514d9f00576f42942d50a5ca0e4b0342b5914e19a8ebc10ce1450b00a3b9c1bf0ce01909bca3ffdead1aa3a791a97b5ac1b'
}
```

## Backwards Compatibility
<!-- All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright. The authors should answer the question: "Does this KIP require a hard fork?" -->
- [caver-js](https://docs.klaytn.foundation/content/dapp/sdk/caver-js/v1.4.1/api-references/caver.klay.accounts#sign) already sign in this format.
- [caver-java](https://javadoc.io/doc/com.klaytn.caver/core/1.10.0/com/klaytn/caver/wallet/keyring/PrivateKey.html) already sign in this format.


## Reference
[EIP-191](https://eips.ethereum.org/EIPS/eip-191)

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
