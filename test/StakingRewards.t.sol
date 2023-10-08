// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {StakingRewrds} from "../src/StakingRewards.sol";
import {MarsIfeanyi} from "../src/MarsIfeanyi.sol";

contract StakingRewrdsTest is Test {
    StakingRewrds public stakingRewrds;
    MarsIfeanyi public marsIfeanyi;

    function setUp() public {
        stakingRewrds = new StakingRewrds();

        marsIfeanyi = new MarsIfeanyi();
    }
}
