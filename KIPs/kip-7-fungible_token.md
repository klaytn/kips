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

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

### Differences with ERC-20
This section describes the differences between KIP-7 and ERC-20. 
- More optional functions are included (e.g. mint, burn and pause extensions).
- Every token transfer/mint/burn MUST be tracked by event logs. This means that a Transfer event MUST be emitted for any action related to transfer/mint/burn.
- The [KIP-13](http://kips.klaytn.com/KIPs/kip-13-interface_query_standard) interface for each method group MUST be implemented.

### KIP-13 Identifiers
The below table shows KIP-13 identifiers for interfaces defined in this proposal.

|Interface|KIP-13 Identifier|
|---|---|
|[IKIP7](#kip7-interface)|0x65787371|
|[IKIP7TokenReceiver](#wallet-interface)|0x9d188c22|
|[IKIP7Metadata](#metadata-extension)|0xa219a025|
|[IKIP7Mintable](#minting-extension)|0xeab83e20|
|[IKIP7Burnable](#burning-extension)|0x3b5a0bf8|
|[IKIP7Pausable](#pausing-extension)|0x4d5507ff|

### KIP7 Interface
```solidity
/// @title KIP-7 Fungible Token Standard
///  Note: the KIP-13 identifier for this interface is 0x65787371.
interface IKIP7 {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to
    /// another (`to`) and created (`from` == 0) and destroyed(`to` == 0).
    ///
    /// Note that `value` may be zero.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set by
    /// a call to {approve}. `value` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the amount of tokens in existence.
    /// @return the total supply of this token.
    function totalSupply() external view returns (uint256);

    /// @notice Returns the amount of tokens owned by `account`.
    /// @param account An address for whom to query the balance
    /// @return the amount of tokens owned by `account.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Moves `amount` tokens from the caller's account to `recipient`.
    /// @dev Throws if the message caller's balance does not have enough tokens to spend.
    /// Throws if the contract is pausable and paused.	
    ///
    /// Emits a {Transfer} event.
    /// @param recipient The owner will receive the tokens.
    /// @param amount The token amount will be transferred.
    /// @return A boolean value indicating whether the operation succeeded.
    function transfer(address recipient, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` will be
    /// allowed to spend on behalf of `owner` through {transferFrom}. This is
    /// zero by default.
    /// @dev Throws if the contract is pausable and paused.	
    ///
    /// This value changes when {approve} or {transferFrom} are called.
    /// @param owner The account allowed `spender` to withdraw the tokens from the account.
    /// @param spender The address is approved to withdraw the tokens.
    /// @return An amount of spender's token approved by owner.
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev Throws if the contract is pausable and paused.
    ///
    /// IMPORTANT: Beware that changing an allowance with this method brings the risk
    /// that someone may use both the old and the new allowance by unfortunate
    /// transaction ordering. One possible solution to mitigate this race
    /// condition is to first reduce the spender's allowance to 0 and set the
    /// desired value afterwards:
    /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    ///
    /// Emits an {Approval} event.
    /// @param spender The address is approved to withdraw the tokens.
    /// @param amount The token amount will be approved.
    /// @return a boolean value indicating whether the operation succeeded.
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Moves `amount` tokens from `sender` to `recipient` using the
    /// allowance mechanism. `amount` is then deducted from the caller's
    /// allowance.
    /// @dev Throw unless the `sender` account has deliberately authorized the sender of the message via some mechanism.
    /// Throw if `sender` or `recipient` is the zero address.
    /// Throws if the contract is pausable and paused.	
    ///
    /// Emits a {Transfer} event.
    /// Emits an `Approval` event indicating the updated allowance.
    /// @param sender The current owner of the tokens.
    /// @param recipient The owner will receive the tokens.
    /// @param amount The token amount will be transferred.
    /// @return A boolean value indicating whether the operation succeeded.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    /// @notice Moves `amount` tokens from the caller's account to `recipient`.
    /// @dev Throws if the message caller's balance does not have enough tokens to spend.
    /// Throws if the contract is pausable and paused.	
    /// Throws if `_to` is the zero address. 
    /// Returns a boolean value indicating whether the operation succeeded.
    /// When transfer is complete, this function checks if `_to` is a smart 
    /// contract (code size > 0). If so, it calls
    ///  `onKIP7Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onKIP7Received(address,address,uint256,bytes)"))`.
    /// @param recipient The owner will receive the tokens.
    /// @param amount The token amount will be transferred.
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransfer(address recipient, uint256 amount, bytes data) external;
    
    
    /// @notice Moves `amount` tokens from the caller's account to `recipient`.
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param recipient The owner will receive the tokens.
    /// @param amount The token amount will be transferred.
    function safeTransfer(address recipient, uint256 amount) external;
    
    /// @notice Moves `amount` tokens from `sender` to `recipient` using the
    /// allowance mechanism. `amount` is then deducted from the caller's
    /// allowance.
    /// @dev Throw unless the `sender` account has deliberately authorized the sender of the message via some mechanism.
    /// Throw if `sender` or `recipient` is the zero address.
    /// Throws if the contract is pausable and paused.
    /// When transfer is complete, this function checks if `_to` is a smart 
    /// contract (code size > 0). If so, it calls
    ///  `onKIP7Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onKIP7Received(address,address,uint256,bytes)"))`.
    /// Emits a {Transfer} event.
    /// Emits an `Approval` event indicating the updated allowance.
    /// @param sender The current owner of the tokens.
    /// @param recipient The owner will receive the tokens.
    /// @param amount The token amount will be transferred.
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address sender, address recipient, uint256 amount, bytes data) external;

    /// @notice Moves `amount` tokens from `sender` to `recipient` using the
    /// allowance mechanism. `amount` is then deducted from the caller's
    /// allowance.
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param sender The current owner of the tokens.
    /// @param recipient The owner will receive the tokens.
    /// @param amount The token amount will be transferred.
    function safeTransferFrom(address sender, address recipient, uint256 amount) external;
}
```

### Wallet Interface
A wallet/broker/auction application MUST implement the **wallet interface** if it will accept safe transfers.

```solidity
/// @title KIP-7 Fungible Token Standard, optional wallet interface
/// @dev Note: the KIP-13 identifier for this interface is 0x9d188c22.
interface IKIP7TokenReceiver {
    /// @notice Handle the receipt of KIP-7 token
    /// @dev The KIP-7 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _amount The token amount which is being transferred.
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onKIP7Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onKIP7Received(address _operator, address _from, uint256 _amount, bytes _data) external returns(bytes4);
}
```

### Metadata Extension
 
The **metadata extension** is OPTIONAL for KIP-7 smart contracts. 
This allows your smart contract to be interrogated for its name and for details about the assets which your token represent.

```solidity
/// @title KIP-7 Fungible Token Standard, optional metadata extension
///  Note: the KIP-13 identifier for this interface is 0xa219a025.
interface IKIP7Metadata {
    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token, usually a shorter version of the
    /// name.
    function symbol() external view returns (string memory);

    /// @notice Returns the number of decimals used to get its user representation.
    /// For example, if `decimals` equals `2`, a balance of `505` tokens should
    /// be displayed to a user as `5,05` (`505 / 10 ** 2`).
    ///  Tokens usually opt for a value of 18, imitating the relationship between
    /// Ether and Wei.
    /// NOTE: This information is only used for _display_ purposes: it in
    /// no way affects any of the arithmetic of the contract, including
    /// `IKIP7.balanceOf` and `IKIP7.transfer`.
    /// @return The number of decimals of this token.
    function decimals() external view returns (uint8);
}
```

### Minting Extension

The **minting extension** is OPTIONAL for KIP-7 smart contracts. This allows your contract to mint tokens.

```solidity
/// @title KIP-7 Fungible Token Standard, optional minting extension
///  Note: the KIP-13 identifier for this interface is 0xeab83e20.
interface IKIP7Mintable {
    /// @notice Creates `amount` tokens and assigns them to `account`, 
    /// increasing the total supply.
    /// @dev Throws if `msg.sender` is not allowed to mint
    /// @param _to The account that will receive the minted token
    /// @param _amount The token amount to mint
    /// @return True if the minting operation is successful, false otherwise
    function mint(address _to, uint256 _amount) external returns (bool);

    /// @notice Check the minting permission
    /// @param _account The account to check the minting permission
    /// @return True if the account has the minting permission, false otherwise
    function isMinter(address _account) external view returns (bool);

    /// @notice Give the minting permission to `_account`
    /// @dev Throws if `msg.sender` is not allowed to mint
    /// @param _account The account to be given the minting permission
    function addMinter(address _account) external;

    /// @notice Renounce the minter permission of `msg.sender`
    /// @dev Throws if `msg.sender` is not allowed to mint
    function renounceMinter() external;
}
```

### Burning Extension

The **burning extension** is OPTIONAL for KIP-7 smart contracts. This allows your contract to burn tokens.

```solidity
/// @title KIP-7 Fungible Token Standard, optional burning extension
///  Note: the KIP-13 identifier for this interface is 0x3b5a0bf8.
interface IKIP7Burnable {
    /// @notice Destroy the specified token
    /// @dev Throws if the message caller's balance does not have enough 
    /// tokens to burn. 
    /// @param _amount The token amount to be burned
    function burn(uint256 _amount) external;

    /// @notice Destroy the specified token from `sender` using allowance 
    /// mechanism. `_amount` is then deducted from the caller's allowance.
    /// @dev Throws if the message caller is `0x0.
    ///   Throws unless the `_account` account has deliberately authorized 
    /// the sender of the message via allowance mechanism.
    /// @param _account The account will be deducted is the The token amount to be burned 
    /// @param _amount The token amount to be burned
    function burnFrom(address _account, uint256 _amount) external;
}
```

### Pausing Extension

The **pausing extension** is OPTIONAL for KIP-7 smart contracts. This allows your contract to be suspended from transferring.

```solidity
/// @title KIP-7 Fungible Token Standard, optional pausing extension
///  Note: the KIP-13 identifier for this interface is 0x4d5507ff.
interface IKIP7Pausable {
    /// @dev This emits when the contract is paused
    event Paused(address _account);

    /// @dev This emits when the contract is unpaused
    event Unpaused(address _account);

    /// @notice Check whether the contract is paused
    /// @return True if the contract is paused, false otherwise    
    function paused() external view returns (bool);

    /// @notice Pause actions related to transfer and approve
    /// @dev Throws if `msg.sender` is not allowed to pause.
    ///   Throws if the contract is paused. 
    function pause() external;

    /// @notice Resume from the paused state of the contract
    /// @dev Throws if `msg.sender` is not allowed to unpause.
    ///   Throws if the contract is not paused. 
    function unpause() external;

    /// @notice Check the pausing permission
    /// @param _account The account to check the pausing permission
    /// @return True if the account has pausing permission, false otherwise
    function isPauser(address _account) external view returns (bool);

    /// @notice Give pausing permission to `_account`
    /// @dev Throws if `msg.sender` is not allowed to pause
    /// @param _account The account to be given the pausing permission
    function addPauser(address _account) external;

    /// @notice Renounce the pausing permission of `msg.sender`    
    /// @dev Throws if `msg.sender` is not allowed to pause
    function renouncePauser() external;
}
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
