# FundMe Smart Contract

## Overview
This is a decentralized crowdfunding platform built with Solidity and Foundry. The contract allows users to send ETH with a minimum contribution requirement based on real-time ETH/USD price feeds from Chainlink.

## Learning Journey
As a second-year student exploring blockchain development, this project represents part of my learning journey through Cyfrin Updraft's Foundry course: **Foundry Fund Me** ([course link](https://updraft.cyfrin.io/courses/foundry/foundry-fund-me/introduction)). While based on Patrick Collins' tutorial within this course, I've made several modifications to understand the concepts better and solve integration challenges.

## Key Features
- Real-time ETH/USD price conversion using Chainlink price feeds
- Minimum contribution requirement ($5 USD equivalent)
- Owner-only withdrawal functionality
- Gas-optimized withdrawal methods
- Comprehensive test coverage including unit and integration tests

## My Modifications
- Fixed integration issues between deployment and interaction scripts by adding a custom deployer address in FundMe.s.sol
- Created separate withdrawal script implementations for different scenarios
- Enhanced testing structure with unit, integration, forking, and mock directories.
- Added detailed NatSpec comments for better code documentation
- Implemented console logging for better debugging and visibility

## Technical Stack
- Solidity ^0.8.19
- Foundry (Forge, Anvil, Cast)
- Chainlink Price Feeds
- Mock Aggregators for testing

## Project Structure
├── src/                       # Smart contract source files
│   ├── FundMe.sol             # Main crowdfunding contract
│   └── PriceConverter.sol     # Price conversion library
├── script/                    # Deployment and interaction scripts
│   ├── FundMe.s.sol           # Deployment script
│   ├── HelperConfig.s.sol     # Network configuration helper
│   └── Interactions.s.sol     # Fund and withdraw scripts
├── test/                       # Test files
│   ├── unit/                   # Unit tests (e.g., FundMe.t.sol)
│   ├── integration/            # Integration tests (e.g., InteractionTest.t.sol)
│   ├── forking/                # Forking tests (e.g., FundMeForking.t.sol)
│   └── mock/                   # Mock contracts (e.g., MockV3Aggregator.sol)
├── foundry.toml                # Foundry configuration file
└── .gitignore                  # Specifies intentionally untracked files

## Integration Challenge Solved
When connecting the deployment script (FundMe.s.sol) to the interaction tests, I encountered an error with script-to-script communication. I solved this by:

1. Adding a custom deployer address in FundMeScript
2. Returning this address from the run() function
3. Using this address in the interaction tests
4. Modifying the startBroadcast pattern to accept this address

## How to Use
1. Clone the repository
2. Install dependencies:
   ```bash
   forge install
   ```
3. Run tests:
   ```bash
   forge test
   ```
4. Deploy to local network:
   ```bash
   forge script script/FundMe.s.sol --broadcast
   ```
5. Interact with the contract:
   ```bash
   forge script script/Interactions.s.sol:FundFundMe --broadcast
   forge script script/Interactions.s.sol:WithdrawFundMe --broadcast
   ```

## What I Learned
- Working with Chainlink price feeds and mock implementations
- Gas optimization techniques for Ethereum contracts
- Foundry testing, deployment, and scripting patterns
- Integrating scripts with test suites
- Troubleshooting cross-script communication issues
- Using NatSpec for professional code documentation

## Future Improvements
- Add a frontend interface
- Implement more complex funding rules
- Add multi-token support
- Explore Layer 2 deployments

## Acknowledgments
- Cyfrin Updraft for the **Foundry Fund Me** course ([course link](https://updraft.cyfrin.io/courses/foundry/foundry-fund-me/introduction)) and Patrick Collins for the original project structure and learning materials.
- The Foundry community for documentation and support.

## License
MIT