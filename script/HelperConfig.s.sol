// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

/**
 * @title HelperConfigScript
 * @notice This script helps set up the price feed configuration for the FundMe contract
 * @dev It determines the correct price feed based on the network being used
 */
contract HelperConfigScript is Script {
    uint8 public constant DECIMALS = 8; // Number of decimals for the price feed
    int256 public constant INITIAL_PRICE = 2000e8; // Initial price for the mock price feed (2000 USD)

    struct NetworkConfig {
        address priceFeed; // Address of the ETH/USD price feed
        uint256 blockConfirmations; // Number of block confirmations needed
    }

    NetworkConfig public activeNetworkConfig; // This stores the active network configuration

    /**
     * @notice Constructor that sets the active network configuration based on the current chain ID
     * @dev It checks which network is being used and sets the price feed accordingly
     */
    constructor() {
        if (block.chainid == 11155111) { // Check for Sepolia network
            activeNetworkConfig = getSepoliaEthConfig(); // Set config for Sepolia
        } else if (block.chainid == 1) { // Check for Mainnet
            activeNetworkConfig = getMainnetEthConfig(); // Set config for Mainnet
        } else if (block.chainid == 31337) { // Check for Hardhat local network
            activeNetworkConfig = getOrCreateAnvilEthConfig(); // Set or create config for Anvil
        } else {
            revert("Unsupported network"); // Revert if the network is not supported
        }
    }

    /**
     * @notice Gets the ETH/USD price feed configuration for the Sepolia network
     * @return sepoliaConfig The network configuration for Sepolia
     */
    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // Sepolia price feed address
            blockConfirmations: block.number // Current block number as confirmation
        });
        return sepoliaConfig; // Return the configuration
    }

    /**
     * @notice Gets the ETH/USD price feed configuration for the Mainnet
     * @return mainnetConfig The network configuration for Mainnet
     */
    function getMainnetEthConfig() public view returns(NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419, // Mainnet price feed address
            blockConfirmations: block.number // Current block number as confirmation
        });
        return mainnetConfig; // Return the configuration
    }

    /**
     * @notice Gets or creates the ETH/USD price feed configuration for the Anvil local network
     * @return anvilConfig The network configuration for Anvil
     */
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // Return existing config if already set
        }

        // Deploying a new mock price feed for testing
        vm.startBroadcast(); // Start broadcasting the transaction
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, 
            INITIAL_PRICE // Deploy a new mock price feed with initial price
        );
        vm.stopBroadcast(); // Stop broadcasting the transaction

        // Create the configuration for Anvil
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed), // Use the address of the deployed mock price feed
            blockConfirmations: block.number // Current block number as confirmation
        });
        return anvilConfig; // Return the configuration
    }
}