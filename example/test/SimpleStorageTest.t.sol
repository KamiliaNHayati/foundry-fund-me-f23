// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test{
    function testDirectStorageWrite() public {
        // Deploy the contract
        SimpleStorage storageContract = new SimpleStorage();
        address contractAddress = address(storageContract);

        // Use vm.store to set slot 0 to 42
        vm.store(contractAddress, bytes32(uint256(0)), bytes32(uint256(42)));

        // Verify the value is now 42
        assertEq(storageContract.value(), 42);
    }
}