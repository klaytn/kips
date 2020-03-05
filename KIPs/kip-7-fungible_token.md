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
This document is heavily derived from [ERC-20](https://eips.ethereum.org/EIPS/eip-20) written by Fabian Vogelsteller and Vitalik Buterin.

### Comparing with ERC-20
Comparing with ERC-20 token standard, this token standard has some differences:
- can include optional functions (e.g. mintable, burnable and pausable methods)
- Every token transfer/mint/burn MUST be tracked by event logs. This means that a Transfer event MUST be emitted for any action related to transfer/mint/burn.
- MUST implement [KIP-13](https://klaytn.github.io/kips/KIPs/kip-interface_query_standard) interface for each method group.

### KIP-7 Identifiers
The below table shows KIP-13 identifiers for interfaces defined in this proposal.

|Interface|KIP-7 Identifier|
|---|---|
|IKIP7|0xXXXXXXXX (TBD)|
|IKIP7Metadata|0xXXXXXXXX (TBD)|
|IKIP7Mint|0xeab83e20|
|IKIP7Burn|0xXXXXXXXX (TBD)|
|IKIP7Pause|0x4d5507ff|

### Summary of Methods and Events
The table below is a summary of methods.
The prototype uses the syntax from Solidity `0.4.24` (or above).
If the optional field is not marked, the function must be implemented.

#### KIP7 Interface
```solidity
/// @title KIP-7 Fungible Token Standard
///  Note: the KIP-13 identifier for this interface is 0xXXXXXXXX.
interface IKIP7 {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to
    /// another (`to`) and created (`from` == 0) and destroyed(`to` == 0).
    ///
    /// Note that `value` may be zero.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set by
    /// a call to {approve}. `value` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @dev Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    /// @dev Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @dev Moves `amount` tokens from the caller's account to `recipient`.
    ///
    /// Returns a boolean value indicating whether the operation succeeded.
    ///
    /// Emits a {Transfer} event.
    function transfer(address recipient, uint256 amount) external returns (bool);

    /// @dev Returns the remaining number of tokens that `spender` will be
    /// allowed to spend on behalf of `owner` through {transferFrom}. This is
    /// zero by default.
    ///
    /// This value changes when {approve} or {transferFrom} are called.
    function allowance(address owner, address spender) external view returns (uint256);

    /// @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
    ///
    /// Returns a boolean value indicating whether the operation succeeded.
    ///
    /// IMPORTANT: Beware that changing an allowance with this method brings the risk
    /// that someone may use both the old and the new allowance by unfortunate
    /// transaction ordering. One possible solution to mitigate this race
    /// condition is to first reduce the spender's allowance to 0 and set the
    /// desired value afterwards:
    /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    ///
    /// Emits an {Approval} event.
    function approve(address spender, uint256 amount) external returns (bool);

    /// @dev Moves `amount` tokens from `sender` to `recipient` using the
    /// allowance mechanism. `amount` is then deducted from the caller's
    /// allowance.
    ///
    /// Returns a boolean value indicating whether the operation succeeded.
    ///
    /// Emits a {Transfer} event.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
```

#### Metadata Extension
 
The detailed extension is OPTIONAL for KIP-7 smart contracts (see "caveats", below). This allows your smart contract to be interrogated for its name and for details about the assets which your NFTs represent.

```solidity
/// @title KIP-7 Fungible Token Standard, optional metadata extension
///  Note: the KIP-13 identifier for this interface is 0xXXXXXXXX.
interface IKIP7Metadata {
    /// @dev Returns the name of the token.
    function name() public view returns (string memory);

    /// @dev Returns the symbol of the token, usually a shorter version of the
    /// name.
    function symbol() public view returns (string memory);

    /// @dev Returns the number of decimals used to get its user representation.
    /// For example, if `decimals` equals `2`, a balance of `505` tokens should
    /// be displayed to a user as `5,05` (`505 / 10 ** 2`).
    ///  Tokens usually opt for a value of 18, imitating the relationship between
    /// Ether and Wei.
    /// NOTE: This information is only used for _display_ purposes: it in
    /// no way affects any of the arithmetic of the contract, including
    /// {IKIP-7-balanceOf} and {IKIP-7-transfer}.
    function decimals() public view returns (uint8);
}
```

#### Minting Extension

The minting extension is OPTIONAL for KIP-7 smart contracts. This allows your contract to mint tokens.

```solidity
/// @title KIP-7 Fungible Token Standard, optional minting extension
///  Note: the KIP-13 identifier for this interface is 0xeab83e20.
interface IKIP7Mint {
    /// @notice Creates `amount` tokens and assigns them to `account`, 
    /// increasing the total supply.
    /// @dev Throws if `msg.sender` is not allowed to mint
    /// @param _to The account that will receive the minted token
    /// @param _amount The token amount to mint
    /// @return True if the minting operation is successful, false otherwise
    function mint(address _to, uint256 _amount) public returns (bool);

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

#### Burning Extension

The burning extension is OPTIONAL for KIP-7 smart contracts. This allows your contract to burn tokens.

```solidity
/// @title KIP-7 Fungible Token Standard, optional burning extension
///  Note: the KIP-13 identifier for this interface is 0xXXXXXXXX.
interface IKIP7Burn {
    /// @notice Destroy the specified token
    /// @dev Throws if the message caller's balance does not have enough 
    /// tokens to burn. 
    /// @param _amount The token amount to be burned
    function burn(uint256 _amount) public;

    /// @notice Destroy the specified token from `sender` using allowance 
    /// mechanism. `_amount` is then deducted from the caller's allowance.
    /// @dev Throws if the message caller is `0x0.
    ///   Throws unless the `_account` account has deliberately authorized 
    /// the sender of the message via allowance mechanism.
    /// @param _account The account will be deducted is the The token amount to be burned 
    /// @param _amount The token amount to be burned
    function burnFrom(address _account, uint256 _amount) public;
}
```

#### Pausing Extension

The pausing extension is OPTIONAL for KIP-7 smart contracts. This allows your contract to be suspended from transferring.

```solidity
/// @title KIP-7 Fungible Token Standard, optional pausing extension
///  Note: the KIP-13 identifier for this interface is 0x4d5507ff.
interface IKIP7Pause {
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
The function MUST fire the [Paused event](#paused). The value of `_account` in the event MUST be set to be the message caller of the method.
The function SHOULD `throw` if the message sender is not a pauser.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

```solidity
function pause() public
```

#### unpause

Unpauses all methods related with token transfer such as transfer, transferFrom and approve methods of the contract. 
The function MUST fire the [Unpaused event](#unpaused). The value of `_account` in the event MUST be set to be the message caller of the method.
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
