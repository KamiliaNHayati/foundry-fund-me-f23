// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SimpleStorage {

    struct Person {
        uint128 age;  // 16 bytes
        uint128 id;   // 16 bytes
        string name;  // Dynamic type
    }

    uint128 public value;
    uint128 public value2;
    uint128 public value3;
    uint256 public value4;
    uint128 private value5;

    Person public person1;
    Person public person2;

    function setValue(uint128 _value) public {
        value = _value;
    }
}
