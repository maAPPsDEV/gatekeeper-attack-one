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

1. Pass Gate 1
   
   Similar to [Telephone](https://github.com/maAPPsDEV/telephone-attack), you can pass Gate 1 by simply letting your contract be the middleman.

2. Pass Gate 3
   
   Gate 3 takes in an 8 byte key, and has the following requirements:
   
```
require(uint32(_gateKey) == uint16(_gateKey));
require(uint32(_gateKey) != uint64(_gateKey));
require(uint32(_gateKey) == uint16(tx.origin));
```
   This means that the integer key, when converted into various byte sizes, need to fulfil the following properties:
   
   - `0x11111111 == 0x1111`, which is only possible if the value is masked by `0x0000FFFF`
   - `0x1111111100001111 != 0x00001111`, which is only possible if you keep the preceding values, with the mask `0xFFFFFFFF0000FFFF`
   
   Calculate the key using the `0xFFFFFFFF0000FFFF` mask:

```
bytes8 key = bytes8(tx.origin) & 0xFFFFFFFF0000FFFF;
```

3. Pass Gate 2
   
   Finally, to pass Gate 2’s `require(msg.gas % 8191 == 0)`, you have to ensure that your remaining gas is an integer multiple of `8191`, at the particular moment when `msg.gas % 8191` is executed in the call stack.

## Security Considerations

- Abstain from asserting gas consumption in your smart contracts, as different compiler settings will yield different results.
- Be careful about data corruption when converting data types into different sizes.
- **Save gas** by not storing unnecessary values. Pushing a value to state `MSTORE`, `MLOAD` is always less gas intensive than store values to the blockchain with `SSTORE`, `SLOAD`
- **Save gas** by using appropriate modifiers to get functions calls for free, i.e. `external pure` or `external view` function calls are free!
- **Save gas** by masking values (less operations), rather than typecasting

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
