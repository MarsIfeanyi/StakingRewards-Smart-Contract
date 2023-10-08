// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {StakingRewrds} from "../src/StakingRewards.sol";
import {MarsIfeanyi} from "../src/MarsIfeanyi.sol";

contract StakingRewrdsTest is Test {
    StakingRewrds public stakingRewrds;
    MarsIfeanyi public marsIfeanyi;

    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    StakingRewrds.StakerData stakerData;

    function setUp() public {
        stakingRewrds = new StakingRewrds(address(marsIfeanyi), WETH);

        marsIfeanyi = new MarsIfeanyi();
    }

    function testStakeETH_ZeroAmountNotAllowed() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                StakingRewrds.ZeroAmountNotAllowed.selector,
                "You can't Stake Zero ETH"
            )
        );
        stakingRewrds.stakeETH{value: 0}();
    }

    function testStakeETH_MustBeGreaterThanMinimumAmountETH() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                StakingRewrds.MustBeGreaterThanMinimumAmountETH.selector,
                "MinimumETH: 0.01 ether"
            )
        );

        stakingRewrds.stakeETH{value: 0.00001 ether}();
    }

    function testWithdrawStakedRewards_MinimumStakingTimeHasNotElapsed()
        public
    {
        stakingRewrds.stakeETH{value: 0.3 ether}();

        vm.warp(1641070800);
        // vm.warp(500000044494885500);

        vm.expectRevert(StakingRewrds.MinimumStakingTimeHasNotElapsed.selector);
        uint _amount = 10 ether;

        stakingRewrds.withdrawStakedRewards(_amount);
    }

    function testWithdrawStakedRewards_CannotWithdrawZeroAmount() public {
        stakingRewrds.stakeETH{value: 0.3 ether}();

        vm.expectRevert(StakingRewrds.CannotWithdrawZeroAmount.selector);

        uint _amount = 10 ether;

        stakingRewrds.withdrawStakedRewards(_amount);
    }
}
