// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockETHLINKAggregator is AggregatorV3Interface {
    int256 public answer;

    constructor(int256 _answer) {
        answer = _answer;
    }

    function decimals() external pure override returns (uint8) {
        return 18;
    }

    function description() external pure override returns (string memory) {
        return "MockETHLINKAggregator";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (uint80 roundId, int256 ans, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        // return (_roundId, answer, block.timestamp, block.timestamp, 1);
        return (1, answer, block.timestamp, block.timestamp, 1);
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 ans, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (1, answer, block.timestamp, block.timestamp, 1);
    }
}
