---
kip: 103
title: Treasury Fund Rebalancing
author: Aidan<aidan.kwon@krustuniverse.com>,Toniya<toniya.sun@krustuniverse.com>
discussions-to: https://govforum.klaytn.foundation/t/kgp-6-proposal-to-establish-a-sustainable-and-verifiable-klay-token-economy/157
status: Draft
type: Standards Track
category : Core
created: 2023-02-24
---

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->
A standard to record the process of rebalancing funds in a transparent manner

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
This standard proposes how to record and rebalance the token allocation when there is a revision to the existing tokenomics in a verifiable and transparent manner. 
 
## Motivation
<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->
Transparency is the one of most important aspect of blockchain. So this standard mainly aims to disclose how the treasury funds are managed transparently through smart contracts. 
A standardized approach would help ensure that treasury fund management is done in a consistent and transparent manner, reducing the risk of errors and mismanagement.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms (klaytn). -->
Treasury Fund Rebalancing includes the below functions 
- Register fund addresses 
- Approve fund allocation 
- Execute  
This is a 3 step process where the order is very important. 

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
 
### Design decision
#### : No Withdrawal
Smart contract is not allowed to receive KLAY due to securiry reasons. So any funds send the contract will be reverted and withdraw function is not implemented. 

#### Design decision: KLAY transfer is not through smart contracts 
As the balance of treasury funds keeps increasing for every block with the block reward its hard to keep track of the balances and rebalance token allocation. So smart contract will record the rebalanced allocation and the core will execute the allocation reading from the contract. 

## Backwards Compatibility
<!-- All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright. The authors should answer the question: "Does this KIP require a hard fork?" -->

- The foundation should deploy new TreasuryRebalance contract to record the token redistribution. 
- To rebalance the funds and redistribute in a consistent manner the foundation should burn the designated funds before allocation. 
- This does not affect the backward compatibility as this a newly dpeloyed contract

## Test Cases
<!--Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.-->
Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.

## Implementation
<!--The implementations must be completed before any KIP is given status "Final", but it need not be completed before the KIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->
#### Example implementation
```solidity

```
## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
