// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

/**
 * @title FundFundMe
 * @notice This script allows users to fund the FundMe contract
 * @dev It uses the Foundry testing framework to interact with the FundMe contract
 */
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether; // Amount to fund the contract with

    /**
     * @notice Funds the FundMe contract with a specified amount
     * @param mostRecentlyDeployed The address of the deployed FundMe contract
     * @param sender The address that will be used to fund the contract
     */
    function fundFundMe(address mostRecentlyDeployed, address sender) public {
        console.log("Current network chainid:", block.chainid); // Log the current network chain ID
        console.log("Contract address:", mostRecentlyDeployed); // Log the address of the FundMe contract
        
        vm.startBroadcast(sender);  // Start broadcasting as the sender
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); // Fund the contract
        vm.stopBroadcast(); // Stop broadcasting
        console.log("Funded FundMe with %s", SEND_VALUE); // Log the funded amount
    }

    /**
     * @notice Runs the funding process
     * @dev This function gets the most recently deployed FundMe contract and calls fundFundMe
     */
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe", 
            block.chainid // Get the address of the most recently deployed FundMe contract
        );
        fundFundMe(mostRecentlyDeployed, msg.sender);  // Call fundFundMe with the sender's address
    }
}

/**
 * @title WithdrawFundMe
 * @notice This script allows the owner to withdraw funds from the FundMe contract
 * @dev It uses the Foundry testing framework to interact with the FundMe contract
 */
contract WithdrawFundMe is Script {
    /**
     * @notice Withdraws funds from the FundMe contract
     * @param mostRecentlyDeployed The address of the deployed FundMe contract
     * @param sender The address that will be used to withdraw funds
     */
    function withdrawFundMe(address mostRecentlyDeployed, address sender) public {
        vm.startBroadcast(sender); // Start broadcasting as the sender
        FundMe(payable(mostRecentlyDeployed)).withdraw(); // Call the withdraw function on the FundMe contract
        vm.stopBroadcast(); // Stop broadcasting
    }

    /**
     * @notice Runs the withdrawal process
     * @dev This function gets the most recently deployed FundMe contract and calls withdrawFundMe
     */
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe", 
            block.chainid // Get the address of the most recently deployed FundMe contract
        );
        withdrawFundMe(mostRecentlyDeployed, msg.sender); // Call withdrawFundMe with the sender's address
    }
}