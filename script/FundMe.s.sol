// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfigScript} from "./HelperConfig.s.sol";

/**
 * @title FundMeScript
 * @notice This script deploys the FundMe contract
 * @dev It uses a helper script to get the price feed address for the network
 */
contract FundMeScript is Script {
    address public deployAddress; // This will hold the address of the deployed FundMe contract
    address DEPLOYER_USER = makeAddr("fundme_deployer"); // This is the address that will deploy the contract

    /**
     * @notice Runs the script to deploy the FundMe contract
     * @return fundMe The deployed FundMe contract
     * @return blockNumber The block number where the contract was deployed
     * @return deployer The address of the deployer
     */
    function run() external returns (FundMe, uint256, address) {
        // Create an instance of the helper config script
        HelperConfigScript helperConfig = new HelperConfigScript();
        // Get the ETH/USD price feed address and the current block number
        (address ethUsdPriceFeed, uint256 blockNumber) = helperConfig.activeNetworkConfig();

        // Start broadcasting the transaction
        vm.startBroadcast(DEPLOYER_USER);
        // Deploy the FundMe contract with the price feed address
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        // Save the deployed contract's address
        deployAddress = address(fundMe);
        // Stop broadcasting the transaction
        vm.stopBroadcast();
        // Return the deployed contract, block number, and deployer address
        return (fundMe, blockNumber, DEPLOYER_USER);
    }
}
