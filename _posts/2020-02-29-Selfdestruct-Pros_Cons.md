---
title: Selfdestruct Pros/Cons
category: Blockchain
tags: [Solidity, Ethereum, Voting]
---

Selfdestruct Pros/Cons
========================

Calling ```selfdestruct(...)``` in a Solidity smart contract (EVM operation ```SELFDESTRUCT``` or ```SUICIDE```, respectively) is probably a good thing:

1. It resets all storage variables of a smart contract.
2. Refunds Gas for this cleanup (see Appendix G. Fee Schedule in the Ethereum Yellow Paper[^1]: $R_{\text{sclear}}$ and $R_{\text{selfdestruct}}$).
3. Transfers the contract's balance to a given account.

But it can be risky! And make things more complex.

> Disclaimer: This pros/cons list does not claim to be complete. I'll update it as soon as I have new points. You are welcome to mail me if you find any missing aspects.

## Pros
- It cleans up the state, so a no longer needed smart contract (with its storage) does not remain in future blocks.
- Refunds for setting storage variables from non-0 to 0.
- Refunds the selfdestruct itself as a bonus, even if the contract doesn't use the storage ($R_{\text{selfdestruct}}$[^1]).
- Transfers the smart contract's individual Ether balance to the specified account (```selfdestruct(account)```).
- It could stop a smart contract which behaves unexpected (like an emergency stop).

## Cons
- It doesn't tell other smart contracts, which use or reference the contract, that it will not be available anymore.
- It's much harder to read out data (manually) from a destructed contract, because the state is not in the current block anymore. For example, someone (not a contract, but a real human) is interested in the results of a voting smart contract, they would have to look back in the blockchain's history, instead of just querying it from the current block (or use a blockchain explorer like [etherscan.io](https://etherscan.io)).
- Additionally, the final results cannot be read by other active contracts anymore, because calls can only be executed on the current state. Smart contracts in Ethereum generally cannot work on old block states.
- Events can't be read anymore (w/o looking back).
- An unauthorized call could transfer the contracts balance to someone unexpected[^2].
- In case of a token contract (e.g., ERC-20[^3]), it refunds the contract's Ether balance, but it keeps (and probably destroys) all of its own tokens.
- It stops the method execution early when its not the last command, like calling ```return``` or ```revert```, and therefore does not allow a function to return a parameter. However, results can be persisted in an event when emitted beforehand.
- Accounts which don't know that they call a destructed smart contract may lose their Gas because the call unexpectedly aborts.
- An account-based authorization check before the self-destruct may contradict with the principles of decentralization and distribution of trust in blockchains.
- The transaction for calling the ```selfdestruct``` method costs a transaction fee (Gas).

## Example: Effects on Time-Based Voting
Let's say we have a very basic voting contract which stops counting new votes at a certain date. The following function can only be called in the following 14 days after the smart contract's deployment. Wouldn't it be handy to self-destruct the smart contract automatically when somebody tries to vote, but the time is over?

```java
uint256 public end = now + 14 days;
mapping(uint256 => uint256) public votes;
address payable owner = msg.sender;

function vote(uint256 _vote) public {
  if(now < end)
    votes[_vote]++; // TODO: check for overflow
  else
    selfdestruct(owner); // owner is the account which deployed the smart contract
}
```

The problem here is, that ```selfdestruct``` sets all non-0 storage values of the contract to 0. Hence, all values in the votes mapping will also be set to 0. But in the case that the votings results are still relevant￼, it would be more complex to get back the results. For this, one would need to find out at which block the contract has been destructed, and then query that block's predecessor state.

The following code, though, persists the voting results as events, which can be monitored by others. But the contract has two major problems: First, it is still complex to query past events of a destructed contract (one has to get an old state and therefore the block number must be known), and second, the last one who calls this function will not get back the function's return value (because ```selfdestruct``` stops the function before it's finished).

```java
uint256 public end = now + 14 days;
mapping(uint256 => uint256) public votes;
address payable owner = msg.sender;

event VoteCounted(uint256 vote);

function vote(uint256 _vote) public returns (bool _successful) {
  if(now < end) {
    _successful = votes[_vote] + 1 > votes[_vote]; // This is an overflow check
    if(_successful) {
      votes[_vote]++; 
      emit VoteCounted(_vote);
    }
  } else {
    _successful = false;
    selfdestruct(owner); // owner contains the account which deployed the smart contract
  }
	
  return _succsessful; // not necessary, see following note
}
```

> Please note here, that calling ```return _succsessful;``` at the end is not necessary, because the return variable is already specified in the function header. It would also be returned even if the ```return``` wouldn't be the last command of the function—except in our special case with ```selfdestruct```.

[^1]: [ethereum.github.io/yellowpaper/paper.pdf](https://ethereum.github.io/yellowpaper/paper.pdf)
[^2]: for example, see [eveem.org/#destruct](https://eveem.org/#destruct), they look for callable selfdestructs automatically
[^3]: [eips.ethereum.org/EIPS/eip-20](https://eips.ethereum.org/EIPS/eip-20)

[//]: # ( #Blockchain #Solidity #Voting )