// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "foundry-devops/src/FoundryZkSyncChecker.sol";

contract ZkSyncDevOps is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    // ZKSyncChainChecker -> This is the package that you can use to only run certain tests on zksync  or only run tests on other evm chains
    // FoundryZkSyncChecker -> This is what u can use to only run certain tests on vanilla foundry or only run on certain tests on zk sync foundry
    
    // Remove the 'skipZkSync', then run 'forge test --mt testZkSyncChainFails --zksync' and this will fail!
    function testZkSyncChainFails() public skipZkSync {
        address ripemd = address(uint160(3));
        bool success;

        assembly {
            success := staticcall(gas(), ripemd, 0, 0, 0, 0)
        }
        assert(success);
    }

    // You'll need 'ffi=true' in your foundry.toml to run this test
    // Remove the 'onlyVanillaFoundry' then run 'foundryup-zksync' and then
    // 'forge test --mt testZkSyncChainFails --zksync'
    // and this will fail!
    function testZkSyncFoundryFails() public onlyVanillaFoundry {
        bool exists = vm.keyExistsJson('{"hi": "true"}', ".hi");
        assert(exists);
    }

    function testZkSyncFoundryFails2() public onlyFoundryZkSync { // add this to check zksync
        bool exists = vm.keyExistsJson('{"hi": "true"}', ".hi");
        assert(exists);
    }
}
