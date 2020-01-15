---
kip: <to be assigned>
title: Fungible Token Standard
author: Junghyun Colin Kim <colin.kim@groundx.xyz>
discussions-to: <URL>
status: Draft
type: Standards Track
category (*only required for Standard Track): Token
created: 2020-01-16
---

<!--You can leave these HTML comments in your merged KIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new KIPs. Note that a KIP number will be assigned by an editor. When opening a pull request to submit your KIP, please use an abbreviated title in the filename, `kip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->
A very first fungible token standard for Klaytn.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
The following standard allows for the implementation of a standard API for tokens within smart contracts.
This standard provides basic functionality to transfer tokens.

## Motivation
<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->
A standard interface allows any tokens on Klaytn to be re-used by other applications: from wallets to decentralized exchanges.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->
This document derived heavily from Ethereum's [ERC-20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) written by Fabian Vogelsteller and Vitalik Buterin.

### Summary of Methods and Events
The table below is a summary of methods.
The prototype uses the syntax from Solidity `0.4.24` (or above).
If the optional field is empty, the function must be implemented.

|Name|Optional|Prototype|
|---|---|---|
|[totalSupply](#totalsupply)| |function totalSupply() public view returns (uint256)|
|[balanceOf](#balanceof)| |function balanceOf(address _owner) public view returns (uint256 balance)|
|[transfer](#transfer)| |function transfer(address _to, uint256 _value) public returns (bool success)|
|[name](#name)|O|function name() public view returns (string)|
|[symbol](#symbol)|O|function symbol() public view returns (string)|
|[decimals](#decimals)|O|function decimals() public view returns (uint8)|

The table below is a summary of events.
The prototype uses the syntax from Solidity `0.4.24` (or above).

|Name|Prototype|
|---|---|
|[Transfer](#transfer-1)|event Transfer(address indexed _from, address indexed _to, uint256 _value)|

### Methods

#### totalSupply

Returns the total token supply.

``` js
function totalSupply() public view returns (uint256)
```



#### balanceOf

Returns the balance of the account specified by the address `_owner`.

``` js
function balanceOf(address _owner) public view returns (uint256 balance)
```



#### transfer

Transfers `_value` amount of tokens to address `_to`, and MUST fire the [Transfer event](#transfer-1).
The function SHOULD `throw` if the message caller's balance does not have enough tokens to spend.

*Note* Transfers of 0 values MUST be treated as normal transfers and fire the [Transfer event](#transfer-1).

``` js
function transfer(address _to, uint256 _value) public returns (bool success)
```


#### name

Returns the name of the token - e.g. `"Klaytn"`.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.


``` js
function name() public view returns (string)
```

#### symbol

Returns the symbol of the token. E.g. "KLAY".

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

``` js
function symbol() public view returns (string)
```



#### decimals

Returns the number of decimals the token uses - e.g. `8`, means to divide the token amount by `100000000` (10^8) to get its user representation.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

``` js
function decimals() public view returns (uint8)
```

### Events
#### Transfer

MUST trigger when tokens are transferred including zero value transfers.

A token contract which creates new tokens SHOULD trigger a Transfer event with the `_from` address set to `0x0` when tokens are created.

``` js
event Transfer(address indexed _from, address indexed _to, uint256 _value)
```



## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
Since functions related to approval of spending tokens in ERC-20 can be defined as a separate token standard, they will be defined in another KIP.

## Backwards Compatibility
<!-- All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright. The authors should answer the question: "Does this KIP require a hard fork?" -->
Since this is the first token standard, it does not need to consider backward compatibility.

## Test Cases
<!--Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.-->
Not available.

## Implementation
<!--The implementations must be completed before any KIP is given status "Final", but it need not be completed before the KIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->
The implementation is not necessary for token standards. The implementation of this will be attached in this section.

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
