// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {StakingRewrds} from "../src/StakingRewards.sol";
import {MarsIfeanyi} from "../src/MarsIfeanyi.sol";

contract StakingRewrdsTest is Test {
    StakingRewrds public stakingRewrds;
    MarsIfeanyi public marsIfeanyi;

    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        stakingRewrds = new StakingRewrds(address(marsIfeanyi), WETH);

        marsIfeanyi = new MarsIfeanyi();
    }
}
