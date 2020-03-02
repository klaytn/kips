---
kip: 7
title: Fungible Token Standard
author: Junghyun Colin Kim <colin.kim@groundx.xyz>, Kyungup Kim <ethan.kim@groundx.xyz>
discussions-to: https://github.com/klaytn/kips/issues/9
status: Draft
type: Standards Track
category: Token
created: 2020-02-20
---

<!--You can leave these HTML comments in your merged KIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new KIPs. Note that a KIP number will be assigned by an editor. When opening a pull request to submit your KIP, please use an abbreviated title in the filename, `kip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->
A fungible token standard for Klaytn.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
The following standard allows for the implementation of a standard API for tokens within smart contracts.
This standard provides basic functionality to transfer tokens.

## Motivation
<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->
A standard interface allows any token on Klaytn to be re-used by other applications: from wallets to decentralized exchanges.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->
This document derived heavily from Ethereum's [ERC-20 token standard](https://eips.ethereum.org/EIPS/eip-20) written by Fabian Vogelsteller and Vitalik Buterin.
Comparing with ERC-20 token standard, this token standard has two differences:
- includes three more optional functions (mint, burn, and burnFrom)
- MUST trigger transfer events when minting and burning tokens

### Summary of Methods and Events
The table below is a summary of methods.
The prototype uses the syntax from Solidity `0.4.24` (or above).
If the optional field is not marked, the function must be implemented.

#### Common Methods 

|Name|Optional|Prototype|
|---|:---:|---|
|[totalSupply](#totalsupply)| |function totalSupply() public view returns (uint256)|
|[balanceOf](#balanceof)| |function balanceOf(address _owner) public view returns (uint256 balance)|
|[transfer](#transfer)| |function transfer(address _to, uint256 _value) public returns (bool success)|
|[transferFrom](#transferfrom)| |function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)|
|[approve](#approve)| |function approve(address _spender, uint256 _value) public returns (bool success)|
|[allowance](#allowance)| |function allowance(address _owner, address _spender) public view returns (uint256 remaining)|
|[name](#name)|O|function name() public view returns (string)|
|[symbol](#symbol)|O|function symbol() public view returns (string)|
|[decimals](#decimals)|O|function decimals() public view returns (uint8)|

#### Mint Methods (Optional)
The table below is a summary of methods related to generating new tokens.
These methods are optional.

|Name|Prototype|
|---|---|
|[mint](#mint)|function mint(address _to, uint256 _value) public returns (bool) |
|[isMinter](#isminter)|function isMinter(address _account) public view returns (bool) |
|[addMinter](#addminter)|function addMinter(address _account) public |
|[renounceMinter](#renounceminter)|function renounceMinter() public |

#### Burn Methods (Optional)
The table below is a summary of methods related to destroying tokens.
These methods are optional.

|Name|Prototype|
|---|---|
|[burn](#burn)|function burn(uint256 _value) public |
|[burnFrom](#burnfrom)|function burnFrom(address _from, uint256 _value) public |

#### Pause Methods (Optional)
The table below is a summary of methods related to suspending a token contract.
These methods are optional.

|Name|Prototype|
|---|---|
|[paused](#paused)|function paused() public view returns (bool) |
|[pause](#pause)|function pause() public |
|[unpause](#burnfrom)|function unpause() public |
|[isPauser](#isminter)|function isPauser(address _account) public view returns (bool) |
|[addPauser](#addminter)|function addPauser(address _account) public |
|[renouncePauser](#renounceminter)|function renouncePauser() public |


#### Events

The table below is a summary of events.
The prototype uses the syntax from Solidity `0.4.24` (or above).
All the following events must be implemented.

|Name|Prototype|
|---|---|
|[Transfer](#transfer-1)|event Transfer(address indexed _from, address indexed _to, uint256 _value)|
|[Approval](#approval)|event Approval(address indexed _owner, address indexed _spender, uint256 _value)|
|[MinterAdded](#minteradded)|event MinterAdded(address indexed _account)|
|[MinterRemoved](#minterremoved)|event MinterRemoved(address indexed _account)|
|[Paused](#paused)|event Paused(address _account)|
|[Unpaused](#unpaused)|event Unpaused(address _account)|
|[PauserAdded](#pauseradded)|event PauserAdded(address indexed _account)|
|[PauserRemoved](#pauserremoved)|event PauserRemoved(address indexed _account)|
     

### Methods

#### totalSupply

Returns the total token supply.

```solidity
function totalSupply() public view returns (uint256)
```

#### balanceOf

Returns the balance of the account specified by the address `_owner`.

```solidity
function balanceOf(address _owner) public view returns (uint256 balance)
```


#### transfer

Transfers `_value` amount of tokens to address `_to`, and MUST fire the [Transfer event](#transfer-1).
The function SHOULD `throw` if the message caller's balance does not have enough tokens to spend.
The function SHOULD `throw`, if the contract is pausable and paused.

*Note* Transfers of 0 values MUST be treated as normal transfers and fire the [Transfer event](#transfer-1).

```solidity
function transfer(address _to, uint256 _value) public returns (bool success)
```

#### transferFrom

The `transferFrom` method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf.
This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in sub-currencies.
The function SHOULD `throw` unless the `_from` account has deliberately authorized the sender of the message via some mechanism.
The function SHOULD `throw`, if the contract is pausable and paused.

*Note* Transfers of 0 values MUST be treated as normal transfers and fire the `Transfer` event.

```solidity
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
```


#### approve

Allows `_spender` to withdraw from your account multiple times, up to the `_value` amount. If this function is called again, it overwrites the current allowance with `_value`.
The function SHOULD `throw`, if the contract is pausable and paused.

**NOTE**: To prevent attack vectors like the one [described here](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/) and discussed [here](https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729),
clients SHOULD make sure to create user interfaces in such a way that they set the allowance first to `0` before setting it to another value for the same spender.
THOUGH The contract itself shouldn't enforce it, to allow backwards compatibility with contracts deployed before.

```solidity
function approve(address _spender, uint256 _value) public returns (bool success)
```


#### allowance

Returns the amount which `_spender` is still allowed to withdraw from `_owner`.

```solidity
function allowance(address _owner, address _spender) public view returns (uint256 remaining)
```

#### name

Returns the name of the token - e.g. `"MyToken"`.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.


```solidity
function name() public view returns (string)
```


#### symbol

Returns the symbol of the token. - e.g. `"MT"`.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function symbol() public view returns (string)
```


#### decimals

Returns the number of decimals the token uses - e.g. `8`, means to divide the token amount by `100000000` (10^8) to get its user representation.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function decimals() public view returns (uint8)
```

#### mint

Mints `_value` amount of tokens to address `_to`, and MUST fire the [Transfer event](#transfer-1). The value of `_from` MUST be set to `0x0` in the transfer event.
The function SHOULD `throw` if the `_to` is `0x0`.
The function SHOULD `throw` if the message sender is not a minter.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function mint(address _to, uint256 _value) public returns (bool)
```

#### isMinter

Returns `true` if `_account` is a minter or `false` if `_account` is not a minter. 

```solidity
function isMinter(address _account) public view returns (bool)
```

#### addMinter

Adds `_account` as a minter, and MUST fire the [MinterAdded event](#minteradded). The value of `_account` MUST be set with same account of `addMinter` method in the `MinterAdded` event.
The function SHOULD `throw` if the `_account` is already a minter.
The function SHOULD `throw` if the message sender is not a minter.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function addMinter(address _account) public 
```

#### renounceMinter

Removes the message sender from minters, and MUST fire the [MinterRemoved event](#minterremoved). The value of `_account` MUST be set with the message sender of `renounceMinter` method in the `MinterRemoved` event.
The function SHOULD `throw` if the message sender is not a minter.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function renounceMinter() public
```

#### burn

Burns `_value` amount of tokens and MUST fire the [Transfer event](#transfer-1). The value of `_from` MUST be set to the token owner's address and the value of `_to` MUST be set to `0x0` in the transfer event.
The function SHOULD `throw` if the message caller's balance does not have enough tokens to burn.

*Note* Burns of 0 values MUST be treated as normal transfers and fire the [Transfer event](#transfer-1).

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function burn(uint256 _value) public
```

#### burnFrom

The `burnFrom` method is used for a withdraw / burn workflow, allowing contracts to burn tokens on your behalf.
This can be used for example to allow a contract to burn tokens on your behalf.
The function MUST fire the [Transfer event](#transfer-1). The value of `_from` MUST be set to the token owner's address and the value of `_to` MUST be set to `0x0` in the transfer event.
The function SHOULD `throw` unless the `_from` account has deliberately authorized the sender of the message via some mechanism.
The function SHOULD `throw` if the sender is `0x0`.

*Note* Burns of 0 values MUST be treated as normal transfers and fire the [Transfer event](#transfer-1).

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function burnFrom(address _from, uint256 _value) public 
```

#### paused

Returns `true` if the contract is paused or `false` if the contract is not paused.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function paused() public view returns (bool) 
```

#### pause

Pauses all methods related with token transfer such as transfer, transferFrom and approve methods of the contract. 
The function MUST fire the [Paused event](#paused). The value of `_account` MUST be set to be the message caller of the method.
The function SHOULD `throw` if the message sender is not a pauser.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function pause() public
```

#### unpause

Unpauses all methods related with token transfer such as transfer, transferFrom and approve methods of the contract. 
The function MUST fire the [Unpaused event](#unpaused). The value of `_account` MUST be set to be the message caller of the method.
The function SHOULD `throw` if the message sender is not a pauser.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function unpause() public 
```

#### isPauser

Returns `true` if `_account` is a pauser or `false` if `_account` is not a pauser. 

```solidity
function isPauser(address _account) public view returns (bool)
```

#### addPauser

Adds `_account` as a pauser, and MUST fire the [PauserAdded event](#pauseradded). The value of `_account` MUST be set with same account of `addPauser` method in the `PauserAdded` event.
The function SHOULD `throw` if the `_account` is already a pauser.
The function SHOULD `throw` if the message sender is not a pauser.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function addPauser(address _account) public 
```

#### renouncePauser

Removes `_account` from pauser, and MUST fire the [PauserRemoved event](#pauserremoved). The value of `_account` MUST be set with same account of `renouncePauser` method in the `PauserRemoved` event.
The function SHOULD `throw` if the message sender is not a pauser.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function renounceMinter() public
```


### Events
#### Transfer

MUST trigger when tokens are transferred including zero value transfers.

A token contract which mints new tokens MUST trigger a Transfer event with the `_from` address set to `0x0` when tokens are created.
A token contract which burns tokens MUST trigger a Transfer event with the `_to` address set to `0x0` when tokens are burned.

```solidity
event Transfer(address indexed _from, address indexed _to, uint256 _value)
```

#### Approval

MUST trigger on any successful call to `approve(address _spender, uint256 _value)`.

```solidity
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```

#### MinterAdded

MUST trigger on any successful call to `addMinter(address _account)`.

```solidity
event MinterAdded(address indexed _account)
```

#### MinterRemoved

MUST trigger on any successful call to `renounceMinter()`.

```solidity
event MinterRemoved(address indexed _account)
```

#### Paused

MUST trigger on any successful call to `pause()`.

```solidity
event Paused(address _account)
```

#### Unpaused

MUST trigger on any successful call to `unpause()`.

```solidity
event Unpaused(address _account)
```

#### PauserAdded

MUST trigger on any successful call to `addPauser(address _account)`.

```solidity
event PauserAdded(address indexed _account)
```

#### PauserRemoved

MUST trigger on any successful call to `renouncePauser()`.

```solidity
event PauserRemoved(address indexed _account)
```

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
This token standard is ERC-20 compliant. If you want to use ERC-20 for Klaytn, you can use this token standard.

## Backwards Compatibility
<!-- All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright. The authors should answer the question: "Does this KIP require a hard fork?" -->
There is no compatibility problem.

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
