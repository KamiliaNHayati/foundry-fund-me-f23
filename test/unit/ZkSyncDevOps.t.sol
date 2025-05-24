// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
// These next two lines pull in some helper tools from a library called "foundry-devops"
// They help write tests that behave differently depending on the Foundry setup.
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "foundry-devops/src/FoundryZkSyncChecker.sol";

/**
 * @title Testing ZkSync and Foundry Setups
 * @notice This file has tests to see how things work with ZkSync (a layer 2 for Ethereum)
 *         and the normal Foundry setup.
 * @dev Special tools from `foundry-devops` are used to make some tests run only in
 *      certain environments.
 *      - `ZkSyncChainChecker`: Used to say "only run this test if on ZkSync" or "only if NOT on ZkSync".
 *      - `FoundryZkSyncChecker`: Used to say "only run this if using regular Foundry" or "only if using Foundry made for ZkSync".
 */
contract ZkSyncDevOps is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    /**
     * @notice This test checks something that is expected to NOT work correctly on ZkSync.
     * @dev It tries to use a specific Ethereum feature (RIPEMD-160 precompile).
     *      ZkSync might not have this, or it might work differently.
     *      The `skipZkSync` part means: "Don't run this test if on a ZkSync network."
     *      If you want to see it fail on ZkSync, you can:
     *      1. Remove `skipZkSync` from the function line.
     *      2. Try running: `forge test --mt testZkSyncChainFails --zksync`
     */
    function testZkSyncChainFails() public skipZkSync {
        address ripemdPrecompile = address(uint160(3)); // This is the address for RIPEMD-160
        bool itWorked;

        // This 'assembly' block is low-level code. It tries to call the precompile.
        assembly {
            itWorked := staticcall(gas(), ripemdPrecompile, 0, 0, 0, 0)
        }
        // This assertion is expected to pass on normal Ethereum chains.
        assert(itWorked);
    }

    /**
     * @notice This tests a Foundry feature (`vm.keyExistsJson`) in the normal Foundry setup.
     * @dev `vm.keyExistsJson` checks if a key is present in JSON text.
     *      It uses something called FFI, which allows Solidity to interact with the file system.
     *      The `onlyVanillaFoundry` part means: "Only run this test with regular Foundry, not ZkSync-Foundry."
     *      For this test to work, `ffi = true` must be set in your `foundry.toml` file.
     *      If you want to see what happens with ZkSync-Foundry:
     *      1. Remove `onlyVanillaFoundry`.
     *      2. Ensure ZkSync-Foundry is set up (`foundryup-zksync`).
     *      3. Run: `forge test --mt testZkSyncFoundryFails --zksync` (this test might fail or behave unexpectedly).
     */
    // function testZkSyncFoundryFails() public onlyVanillaFoundry {
        // Commented out due to issues in CI
        // bool keyWasFound = vm.keyExistsJson('{"hi": "true"}', ".hi");
        // assert(keyWasFound); // Expecting to find the key "hi".
    // }

    /**
     * @notice This also tests `vm.keyExistsJson`, but specifically for Foundry set up for ZkSync.
     * @dev The `onlyFoundryZkSync` part means: "Only run this if using the ZkSync version of Foundry."
     *      This ensures that normal Foundry features (like this FFI one) still work with ZkSync tools.
     */
    // function testZkSyncFoundryFails2() public onlyFoundryZkSync {
        // Commented out due to issues in CI
        // bool keyWasFound = vm.keyExistsJson('{"hi": "true"}', ".hi");
        // assert(keyWasFound); // Expecting to find "hi".
    // }
}
