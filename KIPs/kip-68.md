---
kip: 68
title: Increase Gcallstipend gas in the CALL OPCODE
author: Jasper Lee <@astean1001>
discussions-to: https://github.com/klaytn/kips/issues/68
status: Draft
type: Standards Track
category: Core
created: 2022-03-15
---

## Simple Summary
Increase the Gcallstipend fee parameter in the CALL OPCODE from 2,300 to 3,500 gas units.

## Abstract
Currently, the CALL OPCODE forwards a stipend of 2,300 gas units for a non zero value CALL operations where a contract is called. 
This stipend is given to the contract to allow execution of its fallback function. 
The stipend given is intentionally small in order to prevent the called contract from spending the call gas or performing an attack (like re-entrancy). 
While the stipend is small it should still give the sufficient gas required for some cheap OPCODES like LOG, 
but it's not enough for some more complex and modern logics to be implemented.
This KIP proposes to increase the given stipend from 2,300 to 3,500 to increase the usability of the fallback function.

## Motivation
The main motivation behind this KIP is to allow simple fallback functions to be implemented for contracts following the "Proxy" pattern. 
Simply explained, a "Proxy Contract" is a contract which use DELEGATECALL in its fallback function to behave according to the logic of 
another contract and serve as an independent instance for the logic of the contract it points to. 
This pattern is very useful for saving gas per deployment (as Proxy contracts are very lean) and 
it opens the ability to experiment with upgradability of contracts. 
On average, the DELEGATECALL functionality of a proxy contract costs about 1,000 gas units. 
When a contract transfers KLAY to a proxy contract, the proxy logic will consume about 1,000 gas 
units before the fallback function of the logic contract will be executed. This leaves merely about 1,300 gas units for the execution of the logic. 
This is a severe limitation as it is not enough for an average LOG operation (it might be enough for a LOG with one parameter). 
By slightly increasing the gas units given in the stipend we allow proxy contracts have proper fallback logic without increasing 
the attack surface of the calling contract.

## Specification
Increase the Gcallstipend fee parameter in the CALL OPCODE from 2,300 to 3,500 gas units (further specification will be provided later).

## Rationale
The rational for increasing the Gcallstipend gas parameter by 1,200 gas units comes from the cost of performing DELEGATECALL 
and SLOAD with a small margin for some small additional operations. All while still keeping the stipend relatively small.

## Backwards Compatibility
This KIP requires a backwards incompatible change for the Gcallstipend gas parameter in the CALL OPCODE.

## Test Cases
Test case will be provided later

## Implementation
Implementation will be provided later

## Reference
- https://eips.ethereum.org/EIPS/eip-1285
- [Proxy Call Overhead](https://gist.github.com/GNSPS/ba7b88565c947cfd781d44cf469c2ddb#gistcomment-2383950)
- https://forum.klaytn.com/t/gas-fee-baobab-transfer/4364

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).