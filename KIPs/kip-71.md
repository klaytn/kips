---
kip: 71
title: Dynamic Gas Fee Pricing Mechanism
author: Woojin Lee (jared) <jared.fi@krustuniverse.com>, Junghyun Colin Kim <colin.klaytn@krustuniverse.com>
discussions-to: https://forum.klaytn.com/t/en-new-transaction-fee-mechanism-dynamic-gas-price-proposal/4844 
status: Draft
type: Standards Track
category: Core
created: 2022-04-14
---

<!--You can leave these HTML comments in your merged KIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new KIPs. Note that a KIP number will be assigned by an editor. When opening a pull request to submit your KIP, please use an abbreviated title in the filename, `kip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the KIP.-->
A dynamic gas fee pricing mechanism based on network usage, that includes fixed-per-block network fee that is partially burned.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
There is a base fee per gas in protocol, which can move up or down for each block according to a formula which is a function of the gas used in the parent block and the gas target. The algorithm results in the base fee per gas increasing when the gas used in the previous block is above the gas target, and decreasing when the gas used in the previous block is below the gas target. It repeats until base fee reaches the lower bound fee or the upper bound fee. The base fee per gas is partially burned. Transactions specify the maximum fee per gas they are willing to pay in total. The transaction will always pay the base fee per gas of the block it was included in.
 

## Motivation
<!--The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.-->

Klaytn has been following a policy of “fixed gas price“, with the gas price fixed at a certain level (e.g. 25 ston, 750 ston). This approach was adopted in the initial phase because it allows users to easily send transactions easily without having to enter the gas fee, while minimizing the volatility of transaction fees. But in the periods leading up to the gas price increase, we have seen a lot of transactions on Klaytn as well as the following problems:

* **Delay of transactions** : A large number of transactions were being generated at the same time, leading to increased process time for users. The fundamental cause to this was the sudden surge in transactions. But there were cases of thousands of transactions being fired to process certain transaction have been frequent. And the reason behind this repeated phenomenon was the absence of an algorithm that determines the priority of Klaytn transactions, as well as of an appropriate gas price policy.
* **Storage overload** : The aforementioned bot transactions are created mostly by bots, and are reverted transactions. These transactions strain the Klaytn storage in the long-term, which can hinder Klaytn from providing quick transaction finality and stable network.
* **Inefficient resource allocation due to difficulty in rational price determination** : Gas price should neither be too high or too low. A too low gas price increases vulnerability to DDOS attacks and and transaction delay for users. When it’s too high, the transaction cost is going to prevent users from using the network unreservedly. With the current fixed gas price policy, however, it is difficult to determine which price is appropriate, since the Klaytn network is constantly changing.
* **Inability to respond quickly and flexibly** : Gas price needs to go up during transaction spikes and go down when the network is stable. But under the current fixed gas price scheme, it takes a lot of time until an appropriate price range is discussed and actually implemented.

A burn mechanism is needed to be introduced on Klaytn while solving the above problems, in order to link the growth of the ecosystem with KLAY value.

(This proposal only deals with dynamic fee policy, and a FIFO (First In First Out) transaction priority algorithm is already built at https://github.com/klaytn/klaytn)

## Specification
This specification derived heavily from Ethereum's [ERC-1559](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1559.md) written by Vitalik Buterin (@vbuterin), Eric Conner (@econoar), Rick Dudley (@AFDudley), Matthew Slipper (@mslipper), Ian Norden (@i-norden), Abdelhamid Bakhta (@abdelhamidbakhta).

Transactions under a dynamic gas fee policy consist of `base_fee`, which are dynamically controlled according to the network congestion status. Network congestion is measured by `gas_used` which is the gas usage by blocks created on Klaytn. `base_fee` changes every block.

When a consensus node creates a block, if the `gas_used` of parent_block exceeds `gas_target`, `base_fee` would go up. On the other hand, if the `gas_used` is lower than `gas_target`, the `base_fee` would be reduced. This process would be repeated until the `base_fee` doesn’t exceed `lower_bound` or `upper_bound`. The block proposer would receive a part of the transaction feeds included in the block, and the rest would be burned.


```python
from asyncio.windows_events import NULL
from typing import Union, Dict, Sequence, List, Tuple, Literal
from dataclasses import dataclass, field
from abc import ABC, abstractmethod


# Since Klaytn has multiple transaction types,
# only 3 transaction types are defined here for sake of simplicity.
@dataclass
class TxTypeLegacyTransaction:
	value: int = 0
    to: int = 0
    input: bytes = bytes()
	v: int = 0
	r: int = 0
	s: int = 0
    nonce: int = 0
	gas: int = 0
    gas_price: int = 0

@dataclass
class TxTypeFeeDelegatedSmartContractExecution:
    type: int = 0x09
	nonce: int = 0
	gas_price: int = 0
	gas: int = 0
	to: int = 0
	value: int = 0
	from: int = 0
	input: bytes = bytes()
	tx_signatures: List[int] = field(default_factory=list)
	fee_payer: int = 0 
	fee_payer_signatures: List[int] = field(default_factory=list)

@dataclass
class TxTypeFeeDelegatedSmartContractExecutionWithRatio:
    type: int = 0x32
	nonce: int = 0
	gas_price: int = 0
	gas: int = 0
	to: int = 0
	value: int = 0
	from: int = 0
	input: bytes = bytes()
	fee_ratio: int = 1
	tx_signatures: List[int] = field(default_factory=list)
	fee_payer: int = 0 
	fee_payer_signatures: List[int] = field(default_factory=list)


# In Klaytn, Ethereum transaction types are supported by adding EthereumTxTypeEnvelope(0x78).
# RawTransaction : EthereumTxTypeEnvelope || EthereumTransactionType || TransactionPayload
# (|| is the byte/byte-array concatenation operator.)
# In this proposal, those concatenation is intentionally ommited for simplification.

# Transaction2930 in Ethereum. 
@dataclass
class TxTypeEthereumAccessList:
	type: int = 0x7801
	chain_id: int = 0
	nonce: int = 0
	gas_price: int = 0
	gas: int = 0
	to: int = 0
	value: int = 0
	data: bytes = bytes()
	access_list: List[Tuple[int, List[int]]] = field(default_factory=list)
	v: int = 0
	r: int = 0
	s: int = 0

# Transaction1559 in Ethereum.
@dataclass
class TxTypeEthereumDynamicFee:
	type: int = 0x7802
	chain_id: int = 0
	nonce: int = 0
	gas_tip_cap: int = 0
	gas_fee_cap: int = 0
	gas: int = 0
	to: int = 0
	value: int = 0
	data: bytes = bytes()
	access_list: List[Tuple[int, List[int]]] = field(default_factory=list)
	v: int = 0
	r: int = 0
	s: int = 0


EthereumTransactions = Union[TxTypeEthereumDynamicFee, TxTypeEthereumAccessList]

Transaction = Union[TxTypeLegacyTransaction, TxTypeFeeDelegatedSmartContractExecution, TxTypeFeeDelegatedSmartContractExecutionWithRatio, EthereumTransactions]

# TODO: transaction accounting part
@dataclass
class NormalizedTransaction:
	signer_address: int = 0
	signer_nonce: int = 0
	max_fee_per_gas: int = 0
	gas_limit: int = 0
	to: int = 0
	value: int = 0
	data: bytes = bytes()
	fee_payer_address: int = 0
	fee_ratio: int = 1

@dataclass
class Block:
	hash: int = 0
	parent_hash: int = 0
	base_fee_per_gas: int = 0
	block_score: int = 0
	extra_data: bytes = bytes()
	gas_used: int = 0 
	governance_data: bytes = bytes()
	logs_bloom: int = 0
	number: int = 0
	transaction_receipt_root: int = 0
	reward: int = 0
	state_root: int = 0
	timestamp: int = 0
	timestamp_FoS: int = 0
	transaction_root: int = 0
	nonce: int = 0
	committee: List[int] = field(default_factory=list)
	proposer: int = 0 
	size: int = 0 


@dataclass
class Account:
	type: int = 0
	nonce: int = 0
	humanReadable: bool = False 
	address: int = 0
	key: int = 0 
	balance: int = 0
	storage_root: int = 0
	code_hash: int = 0
	code_format: int = 0
	vm_version: int = 0

INITIAL_FORK_BLOCK_NUMBER = 107806544 # TBD
BASE_FEE_DELTA_REDUCING_DENOMINATOR = 64 # TBD
LOWER_BOUND_BASE_FEE = 2000000000 # TBD, 20ston
UPPER_BOUND_BASE_FEE = 2000000000000 # TBD, 2000ston
GAS_TARGET = 30000000 # TBD
BURN_RATIO = 0.5 # TBD

class World(ABC):
	def validate_block(self, block: Block) -> None:
		
		# check if the base fee is correct
		if INITIAL_FORK_BLOCK_NUMBER == block.number:
			expected_base_fee_per_gas = LOWER_BOUND_BASE_FEE

		else: 
			parent_base_fee_per_gas = self.parent(block).base_fee_per_gas
			parent_gas_used = self.parent(block).gas_used
			transactions = self.transactions(block)

			# check if the base fee is in the range
			if parent_base_fee_per_gas < LOWER_BOUND_BASE_FEE:
				expected_base_fee_per_gas = LOWER_BOUND_BASE_FEE

			elif parent_base_fee_per_gas > UPPER_BOUND_BASE_FEE:
				expected_base_fee_per_gas = UPPER_BOUND_BASE_FEE

			else: 
				# check if the base fee is correct
				if parent_gas_used == GAS_TARGET:
					expected_base_fee_per_gas = parent_base_fee_per_gas
				elif parent_gas_used > GAS_TARGET:
					gas_used_delta = parent_gas_used - GAS_TARGET
					base_fee_per_gas_delta = max(parent_base_fee_per_gas * gas_used_delta // GAS_TARGET // BASE_FEE_DELTA_REDUCING_DENOMINATOR, 1)
					expected_base_fee_per_gas = parent_base_fee_per_gas + base_fee_per_gas_delta
				else:
					gas_used_delta = GAS_TARGET - parent_gas_used
					base_fee_per_gas_delta = parent_base_fee_per_gas * gas_used_delta // GAS_TARGET // BASE_FEE_DELTA_REDUCING_DENOMINATOR
					expected_base_fee_per_gas = parent_base_fee_per_gas - base_fee_per_gas_delta
		
		assert expected_base_fee_per_gas == block.base_fee_per_gas, 'invalid block: base fee not correct'

		# execute transactions and do gas accounting
		cumulative_transaction_gas_used = 0
		for unnormalized_transaction in transactions:
			# Note: this validates transaction signature and chain ID which must happen before we normalize below since normalized transactions don't include signature or chain ID
			signer_address = self.validate_and_recover_signer_address(unnormalized_transaction)
			transaction = self.normalize_transaction(unnormalized_transaction, signer_address)

			signer = self.account(signer_address)

			
			signer.balance -= transaction.amount
			assert signer.balance >= 0, 'invalid transaction: signer does not have enough ETH to cover attached value'
			
			# TODO: fee delegation transaction accounting
			# the signer must be able to afford the transaction
			assert signer.balance >= transaction.gas_limit * transaction.max_fee_per_gas

			# ensure that the user was willing to at least pay the base fee
			assert transaction.max_fee_per_gas >= block.base_fee_per_gas

			# Prevent impossibly large numbers
			assert transaction.max_fee_per_gas < 2**256
			

			signer.balance -= transaction.gas_limit * block.base_fee_per_gas
			assert signer.balance >= 0, 'invalid transaction: signer does not have enough ETH to cover gas'

			gas_used = self.execute_transaction(transaction, block.base_fee_per_gas)
			gas_refund = transaction.gas_limit - gas_used
			cumulative_transaction_gas_used += gas_used
			# signer gets refunded for unused gas
			signer.balance += gas_refund * block.base_fee_per_gas

			# miner only receives some propotion of the base fee(basefee burned)
			self.account(block.proposer).balance += gas_used * block.base_fee_per_gas * BURN_RATIO

		# check if the block spent too much gas transactions
		assert cumulative_transaction_gas_used == block.gas_used, 'invalid block: gas_used does not equal total gas used in all transactions'

		# TODO: verify account balances match block's account balances (via state root comparison)
		# TODO: validate the rest of the block

	def normalize_transaction(self, transaction: Transaction, signer_address: int) -> NormalizedTransaction:
		# legacy transactions
		if isinstance(transaction, TxTypeLegacyTransaction):
			return NormalizedTransaction(
				signer_address = signer_address,
				signer_nonce = transaction.nonce,
				max_fee_per_gas = transaction.gas_price,
				gas_limit = transaction.gas,
				to = transaction.to,
				value = transaction.value,
				data = transaction.input,
				fee_payer_address = None,
				fee_ratio = None
			)

		elif isinstance(transaction, TxTypeFeeDelegatedSmartContractExecution):
			return NormalizedTransaction(
				signer_address = signer_address,
				signer_nonce = transaction.nonce,
				max_fee_per_gas = transaction.gas_price,
				gas_limit = transaction.gas,
				to = transaction.to,
				value = transaction.value,
				data = transaction.input,
				fee_payer_address = transaction.fee_payer,
				fee_ratio = None
			)
		
		elif isinstance(transaction, TxTypeFeeDelegatedSmartContractExecutionWithRatio):
			return NormalizedTransaction(
				signer_address = signer_address,
				signer_nonce = transaction.nonce,
				max_fee_per_gas = transaction.gas_price,
				gas_limit = transaction.gas,
				to = transaction.to,
				value = transaction.value,
				data = transaction.input,
				fee_payer_address = transaction.fee_payer,
				fee_ratio = transaction.fee_ratio
			)
		elif isinstance(transaction, TxTypeEthereumAccessList):
			return NormalizedTransaction(
				signer_address = signer_address,
				signer_nonce = transaction.nonce,
				max_fee_per_gas = transaction.gas_price,
				gas_limit = transaction.gas,
				to = transaction.to,
				value = transaction.value,
				data = transaction.data,
				fee_payer_address = None,
				fee_ratio = None
			)
		elif isinstance(transaction, TxTypeEthereumDynamicFee):
			return NormalizedTransaction(
				signer_address = signer_address,
				signer_nonce = transaction.nonce,
				max_fee_per_gas = transaction.gas_fee_cap,
				gas_limit = transaction.gas,
				to = transaction.to,
				value = transaction.value,
				data = transaction.data,
				fee_payer_address = None,
				fee_ratio = None
			)
		else:
			raise Exception('invalid transaction: unexpected number of items')

	@abstractmethod
	def parent(self, block: Block) -> Block: pass

	@abstractmethod
	def block_hash(self, block: Block) -> int: pass

	@abstractmethod
	def transactions(self, block: Block) -> Sequence[Transaction]: pass

	# effective_gas_price is the value returned by the GASPRICE (0x3a) opcode
	@abstractmethod
	def execute_transaction(self, transaction: NormalizedTransaction, effective_gas_price: int) -> int: pass

	@abstractmethod
	def validate_and_recover_signer_address(self, transaction: Transaction) -> int: pass

	@abstractmethod
	def account(self, address: int) -> Account: pass
```


## Expected Effect

The proposed dynamic gas price mechanism is expected to solve the following problems.
* Reduce transaction process delay and storage overcapacity
* Flexible gas price control depending on the network status
* Introduction of a burn mechanism

But it may give rise to the following changes:
* Edit gas price-related code of the ecosystem wallet and other tools
* Lower predictability of gas price

## Backwards Compatibility

* This implementation will not break backward compatibility.
* But to use this feature, you must use another transaction type which will be implemented with this KIP.
* All previous transaction types will remain the same.


## Reference
- https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1559.md

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
