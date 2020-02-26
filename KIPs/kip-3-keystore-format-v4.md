---
kip: 3
title: Klaytn Keystore Format v4
author: Junghyun Colin Kim <colin.kim@groundx.xyz>
discussions-to: https://github.com/klaytn/klaytn/issues/438
status: Final
type: Standards Track
category: Application
created: 2020-01-03
---

<!--You can leave these HTML comments in your merged KIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new KIPs. Note that a KIP number will be assigned by an editor. When opening a pull request to submit your KIP, please use an abbreviated title in the filename, `kip-draft_title_abbrev.md`. The title should be 44 characters or less.-->
# Klaytn Keystore Format v4

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->
This documentation defines the format of a keystore file which is used to securely store private keys of a Klaytn account.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
Since a Klaytn account can have one or more private keys, the format can provide a better way of storing multiple private keys securely and collectively instead of storing raw private keys.

## Motivation
<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->
Klaytn improves usability by decoupling addresses and key pairs as well as providing various account key types such as multi-signature and role-based keys.
Due to this change, [keystore v3](https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition) is insufficient for Klaytn.
Klaytn keystore format v4 is suitable for Klaytn by storing multiple private keys while it is based on keystore v3.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->

The specification of Klaytn keystore format v4 in JSON for a Klaytn account is shown below.
This format can express various Klaytn account key types such as a single key, multiple keys, and role-based keys. 

```
<keystore> :=
{
  "version": 4,
  "id": <a 128-bit UUID in hexstring>,
  "address": <Klaytn address, a 160-bit hexstring>,
  "keyring": <keyring>
}

<keyring> := [<key> (, <key>)*] | [<keys> (, <keys>)*]

<keys> := [] | [<key> (, <key>)*]

<key> :=
{
  "cipher": "aes-128-ctr",
  "ciphertext": <a 256-bit hexstring>,
  "cipherparams": {
    "iv": <a 128-bit hexstring>
  },
  "kdf": "scrypt" | "pbkdf2",
  "kdfparams": <kdfparams-scrypt> | <kdfparams-pbkdf2>,
  "mac": <a 256-bit hexstring>
}

<kdfparams-scrypt> :=
{
  "dklen": <an integer equal or bigger than 32>,
  "salt": <a 256-bit hexstring>,
  "n": <an integer>,
  "r": <an integer>,
  "p": <an integer>,
}

<kdfparams-pbkdf2> :=
{
  "dklen": <an integer>,
  "salt": <a 256-bit hexstring>,
  "prf": "hmac-sha256",
  "c": <an integer>,
}

```

## Examples
Examples are as following:

1. A single key
    ```
    {
        "version": 4,
        "id": "b6c6bd8f-e3ba-43c1-af4b-1b7dfe13e5f9",
        "address": "0xa8677855999712d23692a4cad77bb9396a1174cd",
        "keyring": [
            {
                "ciphertext": "5cbd3cf235d02718f1cfac84157786d8e36fcf651e15f0c9a4303a2338697126",
                "cipherparams": {
                    "iv": "92a89f3011e020f6a70bb34fddb006c5"
                },
                "cipher": "aes-128-ctr",
                "kdf": "scrypt",
                "kdfparams": {
                    "dklen": 32,
                    "salt": "aa38c864f4f6f538dc3bb4961c9d5d5772b163d2243aa8472cc4f83338e67cd3",
                    "n": 4096,
                    "r": 8,
                    "p": 1
                },
                "mac": "3355abc00f3fb1ae06821ece9c13359a0da1bd284cf29ffc26a534a40d210f28"
            }
        ]
    }
    ```
2. Multiple keys
    ```
    {
        "version": 4,
        "id": "b6c6bd8f-e3ba-43c1-af4b-1b7dfe13e5f9",
        "address": "0xa8677855999712d23692a4cad77bb9396a1174cd",
        "keyring": [
            {
               "ciphertext": "5cbd3cf235d02718f1cfac84157786d8e36fcf651e15f0c9a4303a2338697126",
               "cipherparams": {
                   "iv": "92a89f3011e020f6a70bb34fddb006c5"
               },
               "cipher": "aes-128-ctr",
               "kdf": "scrypt",
               "kdfparams": {
                   "dklen": 32,
                   "salt": "aa38c864f4f6f538dc3bb4961c9d5d5772b163d2243aa8472cc4f83338e67cd3",
                   "n": 4096,
                   "r": 8,
                   "p": 1
                 },
                "mac": "3355abc00f3fb1ae06821ece9c13359a0da1bd284cf29ffc26a534a40d210f28"
            },
            {
               "ciphertext": "5e2f95f61d7af3bebf4ff9f5d5813690c80b0b5aaebd6e8b22d0f928ff06776a",
               "cipherparams": {
                   "iv": "92a89f3011e020f6a70bb34fddb006c5"
               },
               "cipher": "aes-128-ctr",
               "kdf": "scrypt",
               "kdfparams": {
                   "dklen": 32,
                   "salt": "e7c4605ad8200e0d93cd67f9d82fb9971e1a2763b22362017c2927231c2a733a",
                   "n": 4096,
                   "r": 8,
                   "p": 1,
               },
               "mac": "fb86255428e24ba701201d5815f2f2114214cbd34fe4bc7a24b948a8ceac9f9b",
            },
        ]
    }
    ```
3. Role-based keys
    ```
    {
        "version": 4,
        "id": "b6c6bd8f-e3ba-43c1-af4b-1b7dfe13e5f9",
        "address": "0xa8677855999712d23692a4cad77bb9396a1174cd",
        "keyring": [
            [
                {
                "ciphertext": "5cbd3cf235d02718f1cfac84157786d8e36fcf651e15f0c9a4303a2338697126",
                "cipherparams": {
                    "iv": "92a89f3011e020f6a70bb34fddb006c5"
                },
                "cipher": "aes-128-ctr",
                "kdf": "scrypt",
                "kdfparams": {
                    "dklen": 32,
                    "salt": "aa38c864f4f6f538dc3bb4961c9d5d5772b163d2243aa8472cc4f83338e67cd3",
                    "n": 4096,
                    "r": 8,
                    "p": 1
                },
                "mac": "3355abc00f3fb1ae06821ece9c13359a0da1bd284cf29ffc26a534a40d210f28"
            }],
            [],
            [
                {
                   "ciphertext": "5e2f95f61d7af3bebf4ff9f5d5813690c80b0b5aaebd6e8b22d0f928ff06776a",
                   "cipherparams": {
                       "iv": "92a89f3011e020f6a70bb34fddb006c5"
                   },
                   "cipher": "aes-128-ctr",
                   "kdf": "scrypt",
                   "kdfparams": {
                       "dklen": 32,
                       "salt": "e7c4605ad8200e0d93cd67f9d82fb9971e1a2763b22362017c2927231c2a733a",
                       "n": 4096,
                       "r": 8,
                       "p": 1,
                   },
                   "mac": "fb86255428e24ba701201d5815f2f2114214cbd34fe4bc7a24b948a8ceac9f9b",
                },
               {
                   "ciphertext": "5a17fe2af445e63ed2cdda6834d030a9391998000941c79318ab49bff092b9e7",
                   "cipherparams": { 
                     "iv": "38aa896fc128075425e512f01e4b206c" 
                   },
                   "cipher": "aes-128-ctr",
                   "kdf": "scrypt",
                   "kdfparams": {
                       "dklen": 32,
                       "salt": "e7c4605ad8200e0d93cd67f9d82fb9971e1a2763b22362017c2927231c2a733a",
                       "n": 4096,
                       "r": 8,
                       "p": 1,
                   },
                   "mac": "633f91994f33541fbf1c3c3e973e539c12f1dd98f2757f64e3b63de986f367e0",
               },
            ]
        ]
    }
    ```

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
The presentation of keys can be an array or an object for a role-based key.
In this specification, an array is chosen because of the following reasons:

1. Any format has extensibility. If Klaytn introduces a new role, any format can support the new role.
2. The array format is used when RLP-encoding TxTypeAccountUpdate transactions, so the array format is consistent with this.
3. Using an object with special strings as keys can have possibilities to use misspelled keys (e.g., "roleTransactin").

## Backwards Compatibility
<!-- All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright. The authors should answer the question: "Does this KIP require a hard fork?" -->
Klaytn keystore format v4 has a field `keyring` while keystore v3 has a field `crypto` to securely store private keys.
This means v4 is not compatible with v3, hence keystore v3 should also be supported along with the Klaytn keystore format.

## Test Cases
<!--Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.-->
1. The proposed examples above should be accepted.
2. The keystore v3 should also be supported. One example is shown below:
```
{
    "version": 3,
    "id": "7a0a8557-22a5-4c90-b554-d6f3b13783ea",
    "address": "0x86bce8c859f5f304aa30adb89f2f7b6ee5a0d6e2",
    "crypto": {
        "ciphertext": "696d0e8e8bd21ff1f82f7c87b6964f0f17f8bfbd52141069b59f084555f277b7",
        "cipherparams": {
          "iv": "1fd13e0524fa1095c5f80627f1d24cbd" 
        },
        "cipher": "aes-128-ctr",
        "kdf": "scrypt",
        "kdfparams": {
            "dklen": 32,
            "salt": "7ee980925cef6a60553cda3e91cb8e3c62733f64579f633d0f86ce050c151e26",
            "n": 4096,
            "r": 8,
            "p": 1,
        },
        "mac": "8684d8dc4bf17318cd46c85dbd9a9ec5d9b290e04d78d4f6b5be9c413ff30ea4",
    },
}
``` 

## Implementation
<!--The implementations must be completed before any KIP is given status "Final", but it need not be completed before the KIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->
- klaytn
    - https://github.com/klaytn/klaytn/pull/439
    - https://github.com/klaytn/klaytn/pull/440
    - https://github.com/klaytn/klaytn/pull/441
    - https://github.com/klaytn/klaytn/pull/442

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

# Reference
https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition
