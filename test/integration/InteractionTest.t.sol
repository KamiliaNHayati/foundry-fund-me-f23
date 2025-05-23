// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeScript} from "../../script/FundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

/**
 * @title InteractionTest
 * @notice This is a test contract for interacting with the FundMe contract
 * @dev I modified this to learn how to test interactions through scripts
 */
contract InteractionTest is Test {
    FundMe fundMe; // This is the FundMe contract we're testing
    FundMeScript fundMeScript; // This is the script used to deploy FundMe

    // Test user and value constants
    address USER = makeAddr("user"); // Test user address
    uint256 constant SEND_VALUE = 0.1 ether; // Amount to send for funding
    uint256 constant STARTING_BALANCE = 10 ether; // Starting balance for the user

    // The actual deployer address returned from the deployment script
    address actualDeployer;

    /**
     * @notice Set up the test environment before each test
     * @dev This runs before each test to deploy the contract and set balances
     */
    function setUp() external {
        // Deploy the FundMe contract using the deployment script
        fundMeScript = new FundMeScript();
        (fundMe,, actualDeployer) = fundMeScript.run(); // Get the deployed contract and deployer address

        // Give our test user some ETH to work with
        vm.deal(USER, STARTING_BALANCE);
    }

    /**
     * @notice Test that users can fund the contract using the FundFundMe script
     * @dev This checks if the user is added to the funders array correctly
     */
    function testUserCanFundInteractions() public {
        // Create and run the funding script
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe), USER); // User funds the contract

        // Check if the user was added to the funders array
        address funder = fundMe.getFunder(0); // Get the first funder
        assertEq(funder, USER); // Assert that the funder is the user

        // Check the funded amount
        uint256 fundedAmount = fundMe.getAddressToAmountFunded(USER); // Get the amount funded by the user
        assertEq(fundedAmount, SEND_VALUE); // Assert that the funded amount is correct
    }

    /**
     * @notice Test that only the contract owner can withdraw funds
     * @dev This checks if the withdrawal function works correctly
     */
    function testOnlyOwnerCanWithdraw() public {
        // First, fund the contract so there's something to withdraw
        vm.prank(USER); // Pretend to be the user
        fundMe.fund{value: SEND_VALUE}(); // User funds the contract

        // Get the initial balances before withdrawal
        uint256 initialContractBalance = address(fundMe).balance; // Contract's starting balance
        uint256 initialOwnerBalance = actualDeployer.balance; // Owner's starting balance

        // Create and run the withdrawal script
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe), actualDeployer); // Owner withdraws funds

        // Check that the funds were withdrawn correctly
        assertEq(address(fundMe).balance, 0); // Contract balance should be zero
        assertEq(actualDeployer.balance, initialOwnerBalance + initialContractBalance); // Owner's balance should include all funds

        // Try to withdraw as a non-owner (should revert)
        vm.prank(USER); // Pretend to be the user
        vm.expectRevert(); // Expect a revert
        withdrawFundMe.withdrawFundMe(address(fundMe), USER); // User tries to withdraw
    }

    /**
     * @notice Verify the initial state of the contract
     * @dev This checks the owner address and other initial states
     */
    function testInitialState() public view {
        assertEq(fundMe.getOwner(), actualDeployer); // Check if the owner is correct
            // You can add more checks here to verify other initial states
    }
}
