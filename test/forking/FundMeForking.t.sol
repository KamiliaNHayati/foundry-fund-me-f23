// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeScript} from "../../script/FundMe.s.sol";

/**
 * @title FundMeForkingTest
 * @notice This contract tests the FundMe contract using a forked network.
 * @dev This version is modified to help understand how forking works in Foundry.
 */
contract FundMeForkingTest is Test {
    FundMe public fundMe; // The FundMe contract being tested
    address public actualOwner; // The owner of the FundMe contract
    uint256 public deploymentBlock; // The block number when the contract was deployed

    address USER = makeAddr("user"); // A test user address
    uint256 private constant SEND_VALUE = 0.1 ether; // Amount to send for funding
    uint256 private constant STARTING_BALANCE = 10 ether; // Starting balance for the user

    /**
     * @notice Set up the test environment.
     * @dev This function runs before each test to deploy the FundMe contract and set balances.
     */
    function setUp() public {
        // Deploy the FundMe contract using the script
        FundMeScript script = new FundMeScript();
        (fundMe, deploymentBlock,) = script.run(); // Get the deployed contract and block number

        // Set the owner and user balances
        actualOwner = fundMe.getOwner(); // Get the owner address
        vm.deal(actualOwner, STARTING_BALANCE); // Give the owner some starting balance
        vm.deal(USER, STARTING_BALANCE); // Give the user some starting balance
    }

    /// @notice Accept ETH in the test contract
    receive() external payable {}
    fallback() external payable {}

    /**
     * @notice Check that the price feed version is correct.
     * @dev The live Chainlink ETH/USD feed should have version = 4.
     */
    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundMe.getVersion(), 4); // Assert that the version is correct
    }

    /**
     * @notice Test that funding with zero ETH fails.
     * @dev This test expects a revert when trying to fund with no ETH.
     */
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // Expect a revert
        fundMe.fund(); // Try to fund with no ETH
    }

    /**
     * @notice Test that the funded amount is recorded correctly.
     * @dev This test uses a real oracle to convert ETH to USD.
     */
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // Pretend to be the user
        fundMe.fund{value: SEND_VALUE}(); // Fund the contract

        uint256 funded = fundMe.getAddressToAmountFunded(USER); // Get the funded amount
        assertEq(funded, SEND_VALUE); // Check if the amount funded is correct
    }

    /**
     * @notice Test that the funder is added to the list upon funding.
     */
    function testAddsFunderToArray() public {
        vm.prank(USER); // Pretend to be the user
        fundMe.fund{value: SEND_VALUE}(); // Fund the contract

        assertEq(fundMe.getFunder(0), USER); // Check if the first funder is the user
    }

    /**
     * @notice Test that only the owner can withdraw funds.
     * @dev Non-owner calls should revert.
     */
    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER); // Pretend to be the user
        vm.expectRevert(); // Expect a revert
        fundMe.withdraw(); // Try to withdraw as the user
    }

    /**
     * @notice Test that the owner can withdraw funds when only they have funded.
     * @dev This verifies balances before and after withdrawal.
     */
    function testWithdrawWithASingleFunder() public {
        // Arrange
        uint256 ownerStart = actualOwner.balance; // Get the owner's starting balance
        uint256 contractStart = address(fundMe).balance; // Get the contract's starting balance

        // Fund by owner
        vm.prank(actualOwner); // Pretend to be the owner
        fundMe.fund{value: SEND_VALUE}(); // Owner funds the contract

        // Act
        vm.prank(actualOwner); // Pretend to be the owner again
        fundMe.withdraw(); // Owner withdraws funds

        // Assert
        assertEq(address(fundMe).balance, 0); // Check that the contract balance is now zero
        assertEq(actualOwner.balance, ownerStart + contractStart, "Owner balance should include all contract funds"); // Check the owner's balance
    }

    /**
     * @notice Test withdrawal when multiple funders have contributed.
     */
    function testWithdrawFromMultipleFunders() public {
        // Arrange: multiple funders
        for (uint160 i = 1; i <= 10; i++) {
            hoax(address(i), SEND_VALUE); // Pretend to be different users
            fundMe.fund{value: SEND_VALUE}(); // Each user funds the contract
        }
        uint256 ownerStart = actualOwner.balance; // Owner's starting balance
        uint256 contractStart = address(fundMe).balance; // Contract's starting balance

        // Act
        vm.prank(actualOwner); // Pretend to be the owner
        fundMe.withdraw(); // Owner withdraws funds

        // Assert
        assertEq(address(fundMe).balance, 0); // Check that the contract balance is now zero
        assertEq(actualOwner.balance, ownerStart + contractStart); // Check the owner's balance
    }

    /**
     * @notice Test that the gas-optimized withdraw behaves the same as the standard withdraw.
     */
    function testCheaperWithdrawBehavior() public {
        // Arrange
        for (uint160 i = 1; i <= 10; i++) {
            hoax(address(i), SEND_VALUE); // Pretend to be different users
            fundMe.fund{value: SEND_VALUE}(); // Each user funds the contract
        }
        uint256 ownerStart = actualOwner.balance; // Owner's starting balance
        uint256 contractStart = address(fundMe).balance; // Contract's starting balance

        // Act
        vm.prank(actualOwner); // Pretend to be the owner
        fundMe.cheaperWithdraw(); // Owner uses the cheaper withdraw function

        // Assert
        assertEq(address(fundMe).balance, 0); // Check that the contract balance is now zero
        assertEq(actualOwner.balance, ownerStart + contractStart); // Check the owner's balance
    }

    /**
     * @notice Log deployment details for manual inspection.
     * @dev This is a view-only helper, not an assertion test.
     */
    function testLogDeploymentDetails() public view {
        console.log("FundMe at:", address(fundMe)); // Log the contract address
        console.log("Owner:", actualOwner); // Log the owner address
        console.log("Deployed at block:", deploymentBlock); // Log the deployment block number
    }
}
