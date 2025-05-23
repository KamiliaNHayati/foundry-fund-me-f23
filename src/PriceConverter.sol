// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/// @title PriceConverter Library
/// @notice This library helps convert ETH amounts to USD using Chainlink
/// @dev It assumes the price feed returns an 8-decimal price and scales it to 18 decimals
library PriceConverter {
    /// @notice Gets the current ETH price in USD
    /// @param priceFeed The Chainlink price feed to use
    /// @return price The ETH/USD price with 18 decimals
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256 price) {
        // This calls the Chainlink oracle to get the latest price data
        (, int256 answer,,,) = priceFeed.latestRoundData();

        // Chainlink gives 8 decimals but we need 18, so multiply by 10^10
        return uint256(answer) * 1e10;
    }

    /// @notice Converts ETH to USD based on current price
    /// @param ethAmount How much ETH to convert (in wei)
    /// @param priceFeed Which Chainlink feed to usea
    /// @return ethAmountInUsd The USD value in 18 decimal format
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256 ethAmountInUsd)
    {
        uint256 ethPrice = getPrice(priceFeed);

        // Need to divide by 1e18 because both values are in 18 decimals
        // and multiplying them would give 36 decimals
        return (ethPrice * ethAmount) / 1e18;
    }
}
