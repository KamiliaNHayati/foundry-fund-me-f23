// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MockETHLINKAggregator} from "../mock/MockETHLINKAggregator.sol";
import {MockV3Aggregator} from "../mock/MockV3Aggregator.sol";
import {FundMe} from "../../src/FundMe.sol";

/**
 * @title FundMeTest
// Based on PatrickAlphaC’s FundMeTest.sol
// Modified by SecondYearLearner
 * @notice Unit tests for the FundMe contract covering funding and withdrawal logic
 * @dev Uses Forge stdlib and Chainlink mocks to simulate price feeds and edge cases
 */
contract FundMeTest is Test {
    /// @notice FundMe using 18-decimal mock price feed
    FundMe public fundMe;
    /// @notice FundMe using 8-decimal mock price feed
    FundMe public fundMe2;

    /// @notice Test addresses: owner and user
    address OWNER = makeAddr("owner");
    address USER  = makeAddr("user");

    /// @notice Values for funding and balances
    uint256 private constant SEND_VALUE       = 0.1 ether;
    uint256 private constant STARTING_BALANCE = 10 ether;
    uint256 private constant GAS_PRICE        = 1;

    /**
     * @notice Deploy two FundMe contracts with different mock feeds and seed balances
     * @dev mock18 uses 18 decimals, mock8 uses 8 decimals
     */
    function setUp() public {
        MockETHLINKAggregator mock18 = new MockETHLINKAggregator(2000 * 10 ** 18);
        MockV3Aggregator    mock8  = new MockV3Aggregator(8, 2000 * 10**8);

        fundMe  = new FundMe(address(mock18));
        fundMe2 = new FundMe(address(mock8));

        vm.deal(USER, STARTING_BALANCE);
    }

    /// @notice Fallback functions to accept ETH
    receive() external payable {}
    fallback() external payable {}

    /**
     * @notice Ensures the minimum USD funding amount equals $5
     * @dev Verifies MINIMUM_USD constant is 5e18
     */
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    /**
     * @notice Verifies deployer is set as contract owner
     */
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), address(this));
    }

    /**
     * @notice Checks mock price feed version
     * @dev mock feeds return version = 1
     */
    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundMe.getVersion(), 1);
    }

    /**
     * @notice Expect revert when funding with zero ETH
     */
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    /**
     * @notice Expect revert when funding below minimum threshold
     */
    function testRevertFundWithLowEth() public {
        vm.expectRevert("You need to spend more ETH!");
        fundMe2.fund{value: 0.000001 ether}();
    }

    /**
     * @notice Records and reads back funded amount correctly
     */
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    /**
     * @notice Adds funder to internal funders array
     */
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getFunder(0), USER);
    }

    /// @dev Funds contract before executing withdrawal tests
    modifier funded() {
        vm.prank(address(this));
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    /**
     * @notice Only owner can call withdraw
     */
    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    /**
     * @notice Owner withdraws when single funder
     * @dev Contract and owner balances update correctly
     */
    function testWithdrawWithASingleFunder() public {
        vm.deal(address(this), 1 ether);
        uint256 startBalance = address(this).balance;

        vm.txGasPrice(GAS_PRICE);
        fundMe.fund{value: SEND_VALUE}();

        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(address(this).balance, startBalance);
    }

    /**
     * @notice Withdraw from multiple funders resets balances and transfers all
     */
    function testWithdrawFromMultipleFunders() public funded {
        for (uint160 i = 1; i < 10; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 ownerStart = fundMe.getOwner().balance;
        uint256 contractStart = address(fundMe).balance;

        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(ownerStart + contractStart, fundMe.getOwner().balance);
    }

    /**
     * @notice Gas-optimized withdrawal functions correctly
     */
    function testWithdrawFromMultipleFundersCheaper() public funded {
        for (uint160 i = 1; i < 10; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 ownerStart = fundMe.getOwner().balance;
        uint256 contractStart = address(fundMe).balance;

        fundMe.cheaperWithdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(ownerStart + contractStart, fundMe.getOwner().balance);
    }

    /**
     * @notice Supports up to 100 funders
     * @dev This test checks if the contract can handle multiple funders
     */
    function testMaximumFunders() public {
        for (uint256 i = 0; i < 100; i++) {
            hoax(address(uint160(i + 1)), SEND_VALUE); // Pretend to be different users
            fundMe.fund{value: SEND_VALUE}(); // Each user funds the contract
        }
        // Check if the last funder added is the 100th user
        assertEq(fundMe.getFunder(99), address(uint160(100))); // Assert that the last funder is correct
    }

    /**
     * @notice Handles very large funding amounts (1000 ETH) without overflow
     * @dev This test ensures that the contract can handle large funding amounts
     */
    function testMaximumFundingAmount() public {
        uint256 large = 1000 ether; // Set a large funding amount
        vm.deal(USER, large); // Give the user a large balance
        vm.prank(USER); // Pretend to be the user
        fundMe.fund{value: large}(); // User funds the contract with a large amount
        // Check if the funded amount is recorded correctly
        assertEq(fundMe.getAddressToAmountFunded(USER), large); // Assert that the amount funded is correct
    }
}
