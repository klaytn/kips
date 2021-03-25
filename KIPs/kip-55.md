---
kip: 55
title: Klaytn Block generation consensus change proposals
author: KT Ahn "안씨아저씨" <trustfarm.info@gmail.com>
status: Draft
type: Core
category: 
created: 2021-03-23
requires: None
---

## Simple Summary

한글로 된 버전은 클레이튼 [포럼의 토픽 #790](https://forum.klaytn.com/t/topic/790) 을 참조하여 주세요.


Current Klaytn Consensus block generation scheme has target on 1block / 1seconds.
It is very ideal for fast payments confirm and one finality.
But, It makes burden on validator nodes and endpoint nodes.
And, Almost block has 0 TX. 

This IP(Improvement Proposal) is make klaytn networks more broaden and less burden on nodes.
Change default max (deadline) blocktime to 30seconds, and if there's at lease one of TX in TXpool, then generate blocks. it means 1tx/1block/1seconds or 1tx/1block/3seconds ... deadline 30seconds generate blocks.

1Block/1Seconds It makes consume the P2P Network Bandwidth Overhead and Computing power overheads.
because of so heavy block generation makes heavy block overhead itself.

Thus, It is one of big barrier for expand Klaytn ECO. 
It means that whose hope to participates on Klyatn , they needs to spend many money for spend high performance node instance fees or high cost hw.

Also, beginner or no technition , it is hard to join the networks, even though they have good willings on Klaytn.

So, it will finally blocking the Every nodes participates on Klaytn networks.
TX and Block increases remained nodes will very small (except klaytn organization and closed partners).
It will hazardous states on Klaytn blockchain networks, even though Klaytn stance semi-public network or almost private domain network.

## Abstract

This standard outlines a apply deadline block generation policy.
In the aspect of many reasons for improve Klaytn networks.
Above [## Simple Summary] describes all.

## Motivation

Recent days, Klaytn has more interested on investors, developers, thirdparty company. 
they have saying the slow sync problem.
I also tried to sync latest Klaytn EndPoint Node, very longer time spend, compared to Ethereum based chains. Compare with Overall TX counts.

## Specification

1. Deadline blocktime to 30 seconds.
2. if there's no TX , not generates block.
3. if there's atleast 1 TX generates block within deadline time.

Pseudo Code of KIP-55 consensus.
`C` language Style

```
  struct SimpleBlockInfo {
      bignumber blocknumber;
      bytes512  blockhash;
      datetime  generatetime;
  };
  struct SimpleBlockInfo __G_lastBlockinfo;

  void updateLastBlockInfo(BlockObj Block)
  {
      __G_lastBlockinfo.blocknumber = Block->blocknumber;
      memcpy( <<ptr>> (__G_lastBlockinfo.blockhash) , Block->blockhash , 512);
      __G_lastBlockinfo.generatetime = Block->generatetime;
  }

  struct SimpleBlockInfo <<ptr>> getLastBlockInfo( struct <<ptr>>lastBlockinfo )
  {
      lastBlockinfo->blocknumber = __G_lastBlockinfo.blocknumber;
      memcpy( <<ptr>> (lastBlockinfo->blockhash) , <<ptr>> __G_lastBlockinfo.blockhash , 512);
      lastBlockinfo->generatetime = __G_lastBlockinfo.generatetime;
      return <<ptr>> lastBlockinfo;  // self referencing pointer for outer function usability
  }

  OnBlockReceived( BlockObj Block)
  {
      // updates blockinformation
      updateLastBlockInfo(Block);
    
      // ToDo :: legacy jobs.
      ...
  }

  OnBlockGeneration( BlockObj newBlock ) {
      // check conditions 
      // 1> timehas spend over 30Seconds or not
      // 2> check TXpool is not empty
      // 3> is this newblocknumber and blockhash is different than lastblock

      struct SimpleBlockInfo lastBlockinfo;

      getLastBlockInfo( <<ptr>>lastBlockinfo );

      // check blocknumber and blockhash 
      if (    (lastBlockinfo.blocknumber == newBlock->blocknumber) 
           || (lastBlockinfo.blockhash == newBlock->blockhash    )   ) 
           {
               debugLog("new block is same as last one ", newBlock->blocknumber , "\n");
               return;
           }

      // check Time Spend 30Seconds deadline
      if ( diffTime( now(), lastBlockinfo.generatetime) >= 30 )

            // TODO :: GenerateBlock()
            LegacyGenerateBlock(newBlock);

            updateLastBlockInfo(newBlock);
            return;
      )

      // check TX has empty or not
      if ( (newBlock->TxPool->count == 0) || (newBlock->TxPool->Txlist == NULL) )
            return;
    
      // TODO:: GenerateBlock()
      LegacyGenerateBlock(newBlock);

      updateLastBlockInfo(newBlock);
      return;
  }

```

## Validator Economic Model and Motivation to Validator

Validators are responsible to expand ECO or promote Klaytn networks, and securing networks.
If they just funding but no activities increase network usability, finally they loose there funds values.
This model of consensus forces to validators more active, more promotes use of Klaytn networks, for get a more TX mining rewards and Block Rewards.
If there's TX has very low, their Block Rewards to decrease to 1/30.
"No TX mining action!, No Rewards"

## History

1. 21/03/25 :: First Draft :: reference ideation and suggestion links [Forum Topic #790](https://forum.klaytn.com/t/topic/790)
2. 21/03/26 :: Fix Typo :: Adds Validator Economic model **[No TxMining Activity, No Rewards]**

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
