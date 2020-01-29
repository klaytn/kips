---
kip: <to be assigned>
title: Fungible Token Standard With Approval
author: Junghyun Colin Kim <colin.kim@groundx.xyz>
discussions-to: <URL>
status: Draft
type: Standards Track
category (*only required for Standard Track): Token
created: 2020-01-29
requires : 4
replaces (*optional): <KIP number(s)>
---

<!--You can leave these HTML comments in your merged KIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new KIPs. Note that a KIP number will be assigned by an editor. When opening a pull request to submit your KIP, please use an abbreviated title in the filename, `kip-draft_title_abbrev.md`. The title should be 44 characters or less.-->
This is the suggested template for new KIPs.

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->
A fungible token standard with approval.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
Based on the basic fungible token standard, this token standard additionally provides approval.
The token owner can approve tokens to be transferred by another third party.

## Motivation
<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->
A standard interface allows any tokens on Klaytn to be re-used by other applications: from wallets to decentralized exchanges.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->
This document derived heavily from Ethereum's [ERC-20 token standard](https://eips.ethereum.org/EIPS/eip-20) written by Fabian Vogelsteller and Vitalik Buterin.

### Summary of Methods and Events
The table below is a summary of methods.
The prototype uses the syntax from Solidity `0.4.24` (or above).
If the optional field is empty, the function must be implemented.

|Name|Prototype|
|---|---|
|[transferFrom](#transferfrom)|function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)|
|[approve](#approve)|function approve(address _spender, uint256 _value) public returns (bool success)|
|[allowance](#allowance)|function allowance(address _owner, address _spender) public view returns (uint256 remaining)|

The table below is a summary of events.
The prototype uses the syntax from Solidity `0.4.24` (or above).

|Name|Prototype|
|---|---|
|[Approval](#approval)|event Approval(address indexed _owner, address indexed _spender, uint256 _value)|


### Methods
#### transferFrom

Transfers `_value` amount of tokens from address `_from` to address `_to`, and MUST fire the `Transfer` event.

The `transferFrom` method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf.
This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in sub-currencies.
The function SHOULD `throw` unless the `_from` account has deliberately authorized the sender of the message via some mechanism.

*Note* Transfers of 0 values MUST be treated as normal transfers and fire the `Transfer` event.

``` js
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
```



#### approve

Allows `_spender` to withdraw from your account multiple times, up to the `_value` amount. If this function is called again it overwrites the current allowance with `_value`.

**NOTE**: To prevent attack vectors like the one [described here](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/) and discussed [here](https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729),
clients SHOULD make sure to create user interfaces in such a way that they set the allowance first to `0` before setting it to another value for the same spender.
THOUGH The contract itself shouldn't enforce it, to allow backwards compatibility with contracts deployed before.

``` js
function approve(address _spender, uint256 _value) public returns (bool success)
```


#### allowance

Returns the amount which `_spender` is still allowed to withdraw from `_owner`.

``` js
function allowance(address _owner, address _spender) public view returns (uint256 remaining)
```


### Events

#### Approval

MUST trigger on any successful call to `approve(address _spender, uint256 _value)`.

``` js
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```


## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
This token standard is ERC-20 compliant. If you want to use ERC-20 for Klaytn, you can use this token standard.

## Backwards Compatibility
<!-- All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright. The authors should answer the question: "Does this KIP require a hard fork?" -->
No issues for backward compatibility

## Test Cases
<!--Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.-->
Not available.

## Implementation
<!--The implementations must be completed before any KIP is given status "Final", but it need not be completed before the KIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->
The implementation is not necessary for token standards. The implementation of this will be attached in this section later.

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
https://eips.ethereum.org/EIPS/eip-20
