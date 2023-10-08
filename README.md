# Token Staking Contract with an annualized PR of 14%

## Requirements:

- Creating an ERC20 token named after the Github username.
- Accepting only ETH and converting it to WETH.
- Minting a receipt token in proportion to the deposited WETH.
- Distributing the new token as a reward at an APR of 14%.
- Allowing users to opt for auto-compounding with a 1% fee.
- Allowing anyone to trigger the auto-compounding and rewarding them.
- Allow users to withdrawal their staking.

## Features / Functions

- receiptToken = MarsIfeanyi.sol

- constructor()
- stakeEth()
- autoCompound()
- withdrawStake()
- calculateRewards()
- mintReceiptTokens()
- swapRewardsToWeth()
- withdrawStakedRewards()
- withdrawStakedTokensAndRewards()

##### Feature Breakdown

- struct StakerData{

- address staker;
- uint256 amountStaked;
- uint256 reward;
- uint256 timeStaked;
- bool isAutoCompounding;
  }

- Storage/ state variables
- mapping(address =)

- Events

- stakeEth() external payable{

- Preconditions:
  - check that msg.value is not zero()
  - convert ETHAmount to WETHAmount
  - update storage struct
  - calculate 1% autoCompounding
  - Mint receipt tokens
  - emit event

}

- \_mintReceiptToken() internal{

  - preconditions:
    - check that balance of receiptToken, IER20(rMarsIfeanyi.sol) is greater than msg.value;

}

https://github.com/MarsIfeanyi/StakingRewards-Smart-Contract
