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
    uint256 fundingAmount; // Amount to fund the contract with

    /**
     * @notice Funds the FundMe contract with a specified amount
     * @param mostRecentlyDeployed The address of the deployed FundMe contract
     * @param sender The address that will be used to fund the contract
     * @param amountToFund The amount of ETH to send for funding
     */
    function fundFundMe(address mostRecentlyDeployed, address sender, uint256 amountToFund) public {
        // Added amountToFund parameter
        console.log("Current network chainid:", block.chainid);
        console.log("Contract address:", mostRecentlyDeployed);

        vm.startBroadcast(sender);
        FundMe(payable(mostRecentlyDeployed)).fund{value: amountToFund}(); // Use amountToFund parameter
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", amountToFund); // Log amountToFund
    }

    /**
     * @notice Runs the funding process
     * @dev This function gets the most recently deployed FundMe contract and calls fundFundMe
     */
    function run(uint256 amount) external {
        // Changed type to uint256 for consistency
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        // Now call the modified fundFundMe function, passing the amount
        fundFundMe(mostRecentlyDeployed, msg.sender, amount);
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
