# Solidity Game - Gatekeeper Attack

_Inspired by OpenZeppelin's [Ethernaut](https://ethernaut.openzeppelin.com), Gatekeeper One Level_

⚠️Do not try on mainnet!

## Task

Make it past the gatekeeper and register as an entrant.

_Hint:_

1. Remember what you've learned from the [Telephone](https://github.com/maAPPsDEV/telephone-attack) and [Token](https://github.com/maAPPsDEV/token-attack) games.
2. You can learn more about the special function `gasleft()`, in Solidity's documentation (see [here](https://docs.soliditylang.org/en/v0.8.3/units-and-global-variables.html) and [here](https://docs.soliditylang.org/en/v0.8.3/control-structures.html#external-function-calls)).

## What will you learn?

1. How to count gas

   In Ethereum, computations cost money. This is calculated by `gas * gas price`, where `gas` is a unit of computation and `gas price` scales with the load on Ethereum network. The transaction sender needs to pay the resulting ethers for every transaction she/it invokes.
   
   > Complex transactions (like contract creation) costs more than easier transactions (like sending someone some Ethers). Storing data to the blockchain costs more than reading the data, and reading constant variables [costs less](https://github.com/maAPPsDEV/privacy-attack) than reading storage values.
   
   Specifically, `gas` is assigned at the assembly level, i.e. each time an operation happens on the call stack. For example, these are arithmetic operations and their current gas costs, from the [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf) (Appendix H):
   
   ![gas1](https://user-images.githubusercontent.com/78368735/123290733-e3d73d80-d4e7-11eb-856e-7e3de9759940.png)
   
   **Tip**: Use [Remix](http://remix.ethereum.org/) to play `gas`
   
   **Important to know**
   
   Different Solidity **compiler versions** will calculate gas differently. And whether or not **optimization** is enabled will also affect gas usage. Try changing the compiler defaults in Settings tab to see how remaining gas will change.
   
   Before starting this game, make sure you have configured Remix to the correct compiler version.
   
2. Datatype conversions
   
   The second piece of knowledge you need to solve this level is around data conversions. Whenever you convert a datapoint with larger storage space into a smaller one, you will lose and corrupt your data.
   
   ![gas2](https://user-images.githubusercontent.com/78368735/123291305-5cd69500-d4e8-11eb-9bab-4fcd25cf95d0.png)

3. Byte masking
   
   Conversely, if you want to intentionally achieve the above result, you can perform byte masking. Solidity allows such bitwise operations for bytes and ints as follows:

```
bytes4 a = 0xffffffff;
bytes4 mask = 0xf0f0f0f0;
bytes4 result = a & mask ;   // 0xf0f0f0f0
```


## What is the most difficult challenge?

**You won't get success to attack if the target contract has been complied in Solidity 0.8.0 or uppper** 🤔

> [**Solidity v0.8.0 Breaking Changes**](https://docs.soliditylang.org/en/v0.8.5/080-breaking-changes.html?highlight=underflow#silent-changes-of-the-semantics)
>
> Arithmetic operations revert on **underflow** and **overflow**. You can use `unchecked { ... }` to use the previous wrapping behaviour.
>
> Checks for overflow are very common, so we made them the default to increase readability of code, even if it comes at a slight increase of gas costs.

I had tried to do everything in Solidity 0.8.5 at first time, but it didn't work, as it reverted transactions everytime it met underflow.

Finally, I found that Solidity included those checks by defaults while using sliencely more gas.

So, don't you need to use [`SafeMath`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol)?

## Source Code

⚠️This contract contains a bug or risk. Do not use on mainnet!

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {
  mapping(address => uint256) balances;
  uint256 public totalSupply;

  constructor(uint256 _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

```

## Configuration

### Install Truffle cli

_Skip if you have already installed._

```
npm install -g truffle
```

### Install Dependencies

```
yarn install
```

## Test and Attack!💥

### Run Tests

```
truffle develop
test
```

You should take ownership of the target contract successfully.

```
truffle(develop)> test
Using network 'develop'.


Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.



  Contract: Hacker
    √ should steal countless of tokens (377ms)


  1 passing (440ms)

```
