// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Importing the interface for Chainlink price feeds
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
import "forge-std/console.sol"; // For debugging - helped me a lot!

// Custom error to save gas instead of using strings
error NotOwner();

/// @title My FundMe project from Cyfrin course
/// @author PatrickAlphaC (original), modified by me
/// @notice This lets people send ETH to the contract if they meet the minimum USD amount
contract FundMe {
    // This lets us use the library functions directly on uint256 variables
    using PriceConverter for uint256;

    // Need to fund at least $5 worth of ETH
    // I learned that constants save gas!
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    
    // Contract owner who can withdraw funds
    // Using immutable also saves gas compared to regular storage
    address private immutable i_owner;
    
    // List of everyone who sent ETH
    address[] private s_funders;
    
    // Keeping track of how much each address sent
    mapping(address => uint256) private s_addressToAmountFunded;
    
    // Chainlink price feed interface - this was new to me!
    AggregatorV3Interface private s_priceFeed;

    // Constructor runs once when contract is deployed
    constructor(address priceFeedAddress) {
        i_owner = msg.sender; // whoever deploys the contract is the owner
        s_priceFeed = AggregatorV3Interface(priceFeedAddress); // setting up the price feed
    }

    // Main function for users to send ETH to the contract
    function fund() public payable {
        // Make sure they send enough ETH (converted to USD)
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        
        // Record the funding amount for this sender
        s_addressToAmountFunded[msg.sender] += msg.value;
        
        // Add sender to the funders list
        s_funders.push(msg.sender);
    }
    
    // Check the Chainlink price feed version
    // I added this to make sure everything's connected right
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }
    
    // Modifier to restrict certain functions to only the owner
    // This was cool to learn about!
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner();
        _;  // This means "run the rest of the function"
    }
    
    // Owner can withdraw all the ETH from the contract
    function withdraw() public onlyOwner {
        // Loop through all funders and reset their funding amount
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        
        // Reset the funders array to empty
        s_funders = new address[](0);
        
        // Log current balance for debugging
        console.log(address(this).balance);
        
        // There are 3 ways to send ETH: transfer, send, and call
        // Patrick taught that call is best practice now
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
        
        // Log owner's balance after
        console.log(i_owner.balance);
    }

    // This is a gas-optimized version of withdraw that I learned about
    // It's more efficient because it reads from memory instead of storage
    function cheaperWithdraw() public onlyOwner {
        // Copy funders array to memory - this was a new concept for me!
        address[] memory funders = s_funders;
        
        // Loop through memory array (cheaper gas)
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        
        // Reset funders array
        s_funders = new address[](0);
        
        // Send all ETH to the owner
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
    
    // These special functions handle when someone sends ETH directly to the contract
    // I think this diagram really helped me understand:
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund(); // Route through the fund function to apply our checks
    }

    receive() external payable {
        fund(); // Route through the fund function to apply our checks
    }

    // Getter functions to read data from the contract
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly