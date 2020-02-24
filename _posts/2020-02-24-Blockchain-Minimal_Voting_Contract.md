---
title: Minimal Voting Scheme with Solidity
category: Blockchain
tags: [Solidity, Ethereum, Voting]
---

Minimal Voting Scheme with Solidity
=====================================
The most basic voting contract, which allows to vote for a number in a specified range. Voters can vote as often as they wish for a number between $0 &le; \text{number} &le; \text{max}$.
Because the contract uses unsigned[^1] integers for counting, the voting eventually ends once one number reaches $2^{256}-1$ votes (integers in Solidity have 256 bits[^2] unless otherwise specified, e.g., uint8 has 8 bits).

The results of the voting can be read by anybody, as the votes mapping is specified public[^3].

> Disclaimer: This contract does not implement any voting standard like [ERC-1202](https://github.com/xinbenlv/eip-1202/blob/master/EIP-1202.md). It also does not implement [SafeMath](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol), due to its own check mechanisms (the panic switch).

## Without explanations:
```java
pragma solidity >=0.5.0 <0.6.0;

contract MinimalVoting {
  mapping(uint => uint) public votes;
  uint public max;
  bool public panic = false;

  constructor(uint _max) public {
    max = _max;
  }

  function vote(uint number) public {
    require(!panic, "One voting number reached its maximum.");
    require(number <= max, "Invalid vote.");
    votes[number]++;
    panic = votes[number] == 2**256-1;
  }
}
```

## With explanations:

```java
pragma solidity >=0.5.0 <0.6.0; /* Use a 0.5.xx compiler */

contract MinimalVoting { /* The contract's name */
  mapping(uint => uint) public votes; /* A map which relates a voting number to the amount of its votes 
		uint is a datatype for unsigned integers (only positive integers) */
  uint public max; /* limits the number of possible voting numbers */
  bool public panic = false; /* panic switch, which stops voting if a number received the maximum amount of votes by reaching the maximum of an integer */

  constructor(uint _max) public { /* constructor will be called when the contract is created */
    max = _max; /* saves the _max parameter to the storage */
  }

  function vote(uint number) public { /* the actual voting happens here. It expects a number to vote for. */
    require(!panic, "One voting number reached its maximum."); /* Check whether any previuos voting has reached the maximum of an usigned 256-bit unteger */
    require(number <= max, "Invalid vote."); /* check whether the voting is in the specified range */
    votes[number]++; /* save the voting by adding +1 */
    panic = votes[number] == 2**256-1; /* check whether the current vote reached the integer maximum, so it would have to stop the voting */
  }
}
```


## Next Steps
- Timebased ending
- Throwing events
- Adding a selfdestruct
- Prevent double-voting

[^1]: unsigned: only positive numbers
[^2]: maximum number for uint256: 115792089237316195423570985008687907853269984665640564039457584007913129639935
[^3]: public in Solidity only allows external accounts/contracts to read the variable. Unlike in Java/C++ it does not allow to write

[//]: # ( #Blockchain #Solidity #Voting #Ethereum )
