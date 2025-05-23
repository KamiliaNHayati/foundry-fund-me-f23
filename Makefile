-include .env

.PHONY : all test clean deploy fund help install snapshot format anvil

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n  example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n  example: make fund ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install Cyfrin/foundry-devops --no-commit && forge install smartcontractkit/chainlink-brownie-contracts --no-commit &&   forge install foundry-rs/forge-std@v1.8.2 --no-commit

# Update dependencies
update :; forge update

# Build the project
build :; forge build

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 100

NETWORK_ARGS = --rpc-url http://127.0.0.1:8545 --private-key ${PRIVATE_KEY_ANVIL} --broadcast 

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS = --rpc-url ${SEPOLIA_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
endif

deploy:
	@forge script script/FundMe.s.sol:FundMeScript ${NETWORK_ARGS}

fund: 
	@forge script script/Interactions.s.sol:FundFundMe ${NETWORK_ARGS}

withdraw: 
	@forge script script/Interactions.s.sol:WithdrawFundMe ${NETWORK_ARGS}



# build:
# 	forge build

# test:
# 	forge test

# deployFundMe-sepolia:
# 	forge script script/FundMe.s.sol:FundMeScript --rpc-url ${SEPOLIA_RPC_URL} --broadcast --private-key ${PRIVATE_KEY}  --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv 

# deployFundMe-anvil:
# 	forge script script/FundMe.s.sol:FundMeScript --rpc-url 127.0.0.1:8545 --broadcast --private-key ${PRIVATE_KEY_ANVIL} -vvvv 

