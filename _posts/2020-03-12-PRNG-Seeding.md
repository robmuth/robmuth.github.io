---
title: Pseudo Random Number Generator in a Smart Contract with LCG
category: Blockchain
tags: [Solidity, Ethereum, Security]
---

Pseudo Random Number Generator in a Smart Contract with LCG
================================

I often need random numbers in a smart contract for my research.
Or at least, something that looks like *random* numbers.
Bad for me, there is no ```random()``` in Solidity[^1].

The problem of random numbers is basically its source.
Imagine a smart contract is executed by a malicious miner; they could influence the execution of the pseudo random number generator (PRNG) to their advantage.
So, one of my approaches is to pass *secure* random numbers from an external source to the smart contract.
On the one hand, I don't want to trust any third-parties, so that source is me. But on the other hand, I don't want to provide an arbitrary amount of random numbers.
So, I just use one initial *secure* seed that is used to generate the following pseudo random numbers.

> **Very important:** The seed remains secret until the random numbers will be generated. Otherwise, the random numbers could easily be predicted. So, the seed should also not be re-used again, once it's public!

For enhanced security my smart contracts usually use a random unsigned Integer with 256 bits (Solidity type ```uint256```) as initial seed.

> Disclaimer: This is only a methodical proposal, not a *ready for production* solution.

## Example: ```random(uint256 _max) returns (uint256)``` in Solidity
The following function returns a pseudo random generated number with using a [linear congruential generator](https://en.wikipedia.org/wiki/Linear_congruential_generator) (LCG) limited by the parameter ```_max```.
The constant parameters are the same as in Java's runtime library ```java.util.Random```[^2].

```java
uint256 private seed;

uint256 constant modulus_m = 2 ** 48; // ** is the exponential function in Solidity, also commonly written as 2^48 or exp(2, 48)
uint256 constant multiplier_a = 25214903917; // or hex: 0x5DEECE66D
uint256 constant increment_c = 11; // or hex: 0xB0

function setSeed(uint256 _seed) public {
  require(_seed > 0, "Seed should be != 0");
  seed = _seed;
}

function random(uint256 _max) public returns (uint256) {
  require(seed != 0, "Seed not set, yet");
	
  seed = (seed * multiplier_a + increment_c) % _max; // note: it reuses the latest random number as new seed
  return seed;
}
```

> Note: LCG uses the returned random number as seed for the next generation.
> Security hint: the constants were chosen for Java's 64-bit Integer. For 256-bit Integers other parameters might be necessary.

**Output:**
For ```_seed = 0x0804fd5a6e1973ea7803994fcd3f73e5``` and ```_max = 3145```

```javascript
// Executed 6x:
[ 958, 692, 1560, 1376, 2473, 52 ]
```

## Provide a 256-Bit Seed with JavaScript
Providing an external seed is still tricky when using JavaScript's ```Math.random()``` for the first seed, because it only returns a Float with 64 bits[^3]. So, one could pass four seeds, e.g., ```setSeed(uint64 _seed0, uint64 _seed1, uint64 _seed2, uint64 _seed3)```, or an array of seeds:

```java
function setSeed(uint64 _seed0, uint64 _seed1, uint64 _seed2, uint64 _seed3) public {
  // TODO: Check seeds with require()
  seed = _seed0 + (_seed1 << 16) + (_seed2 << 32) + (_seed3 << 48);
}

// or:
function setSeed(uint256[] memory _seeds) public {
  // TODO: Check seeds with require()
  seed = uint256(keccak256(abi.encodePacked(_seeds))); // hashes all seeds alltogether and returns a corresponding uint256
}
```

> Note: The first implementation potentially saves a lot of gas due to much *cheaper* math operations (in terms of Ethereum Gas) and limited parameters.

The array approach can be used for combining seeds from different sources—which could be a good idea. In case of a single source with ```Math.random()``` in JavaScript the call would look like:

```JavaScript
// Make an array with 32 elements, each containing a random number between 0-255 => 32 * 256 (decimal) == 32 * 8 bit == 256 bit
const firstSeed256Bit = [...Array(32)].map(() => parseInt(Math.random() * 256));

// Web3js call
contract.setSeed(firstSeed256Bit).send({from: "0x..."});
```

> Note: Depending on the JavaScript runtime all 32 random numbers still might depend on one single seed, and therefore, the security might only be as strong as with a 64-bit seed.

For better security a *secure pseudo random number generator* can be used for generating the first seed.
With JavaScript it is possible to include, e.g., a NPM package with a secure pseudo random number generator[^4].

## Securing the Seed with an Ownership Check
Don't forget to secure the ```setSeed(...)``` method with an ownership check. Otherwise, malicious users could manipulate the seed before somebody else calls ```random(...)```.

For example:

```java
contract PRNG {
  address private owner = msg.sender; // save the call sender of the smart contract deployment as owner
  
  function setSeed(uint64 _seed0, uint64 _seed1, uint64 _seed2, uint64 _seed3) public {
    require(msg.sender == owner, "Only the owner can set the seed.").
	
    require(_seed0 > 0, "_seed0 should be > 0");
    require(_seed1 > 0, "_seed1 should be > 0");
    require(_seed2 > 0, "_seed2 should be > 0");
    require(_seed3 > 0, "_seed3 should be > 0");
 	
    seed = _seed0 + (_seed1 << 16) + (_seed2 << 32) + (_seed3 << 48);
  
    require(seed != 0, "Initial seed should be > 0").
  }
}
```

Also, make sure that a potentially malicious miner cannot execute ```random(...)``` so often that it returns a value for its advantage. So, it might be necessary to check the permissions in ```random(...)```.

## Don't Trust the Owner / Commitment Scheme
Now, let's assume the owner is capable of generating a secure seed, then they could influence the results of the ```random()``` generator to their own advantage.
So, a *commitment scheme* can be used for securing the seed before the random generator uses it.

The following example shows a lottery smart contract.
First, the owner publishes the hash value of a seed.
Second, other accounts register for the lottery, in which only one randomly selected account can win. The owner can also register, and therefore, the owner has a personal interest to win the lottery.
Third, the owner reveals the seed value to the hash.
Last, the winner will be selected by a random number (with the given seed).

Because the owner can also register, they should not be able to win the lottery by providing an influential seed.
So, the owner has to provide the seed before the random winner has been selected.

```java
contract Lottery {
  address private owner = msg.sender;
  bytes32 private seedHash;
  
  PRNGContract prng; // TODO: Contract with PRNG, e.g., like described above
  
  address[] participants;
  mapping(address => bool) registred;
  
  address winner;
  
  // First
  constructor(bytes32 _seedHash) public {
    seedHash = _seedHash;
  }
  
  // Second
  function register() public {
    require(winner == address(0), "Lottery is already over");
    require(participants.length < 2 ** 256 - 1, "Participants overflow");
    require(registred[msg.sender], "Already a registred participant");
    registred[msg.sender] = true;
    
    participants.push(msg.sender);
  }
  
  function selectWinner(uint256 _seed) public returns (address) {
    require(winner == address(0), "Winner has already been choosen");
    require(msg.sender == owner, "Only the smart contract owner can choose a winner");
    
    // Third
    require(keccak256(_seed) == seedHash, "Saved seed hash does not equal to the hash of the given seed");
    
    // Last
    prng.setSeed(_seed);
    uint256 rand = prng.getRandom(participants.length);
    winner = participants[rand];
    
    return winner;
  }
}
```

For the case one still cannot not trust the contract owner, all participants could also provide a secure random number when registering (with a commitment scheme), and use these seeds all-together for generating a new global seed. But that might lead to unexpected side effects, too.

## Conclusion
**One must be very careful with using a PRNG in smart contracts, as there is no such thing like *real* randomness in computers.**

1. Solidity doesn't have ```random()``` because miners could cheat when they have an interest to the outcome.
2. Using the timestamp is a really bad idea, because miners can influence it very easily.
3. One might use the previous block hash[^1], because the miner cannot not easily influence it (but it might be possible!).
4. The owner can provide a trusted seed, so the smart contract can generate nicely distributed values based on it (which look like random numbers). For example, with a linear congruential generator.
5. If one cannot completely trust the owner, use a commitment-scheme for the seed. Maybe also use other sources (but keep side effects in mind).
6. Keep in mind, that calling ```random(...)``` also influences the following random numbers (by changing the seed every time).
7. Deterministic computers cannot provide *real* random numbers, sorry.

As long as the miner cannot influence the seed (e.g., by including the timestamp or latest block hash), and the seed is secure, the LCG random function returns nicely *distributed* values.


[^1]: Also see Section *Random Numbers* in the Ethereum Yellow Paper: [github.com/ethereum/yellowpaper/blob/7e819ec24cf397a5f0aaf52f00b21702eca78d0a/Paper.tex#L1244](https://github.com/ethereum/yellowpaper/blob/7e819ec24cf397a5f0aaf52f00b21702eca78d0a/Paper.tex#L1244)
[^2]: [developer.classpath.org/doc/java/util/Random-source.html#line.152](http://developer.classpath.org/doc/java/util/Random-source.html#line.152)
[^3]: See IEEE 754 for JavaScript's ```Number``` type
[^4]: [npmjs.com/package/secure-random](https://www.npmjs.com/package/secure-random)

[//]: # ( #Blockchain #Solidity #Security #Ethereum )
