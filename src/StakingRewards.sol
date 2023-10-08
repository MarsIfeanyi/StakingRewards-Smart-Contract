// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {MarsIfeanyi} from "./MarsIfeanyi.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router01} from "./interfaces/IUniswapV2Router01.sol";

contract StakingRewrds {
    using SafeMath for uint256;

    MarsIfeanyi public marsIfeanyi;
    address public immutable WETH;
    address public owner;
    address public WETHtoDeposit;

    struct StakerData {
        address staker;
        uint256 amountStaked;
        uint256 rewards;
        uint256 timeStaked;
        bool isAutoCompounding;
    }
    mapping(address => StakerData) stakingData;

    uint256 constant MINIMUM_AMOUNTETH = 0.01 ether;
    uint256 public stakingCompundingPool;
    address[] public withAutoCompounding;
    address[] public withOutAutoCompounding;

    // Custom Errors
    error ZeroAmountNotAllowed(string);
    error MinimumStakingTimeHasNotElapsed();
    error CannotWithdrawZeroAmount();
    error HeyInsufficientFunds();

    // Events
    event ETHStaked(
        address indexed staker,
        uint256 indexed amountStaked,
        uint256 indexed timeStaked
    );

    event StakedRewardsWithdrawed(
        address indexed staker,
        uint256 indexed amountStaked,
        uint256 timeStaked
    );

    event StakedTokensAndRewardsWithdrawed(
        address indexed staker,
        uint256 indexed totalAmount,
        uint256 indexed rewards
    );

    constructor(address _marsifeanyi, address _WETH) {
        marsIfeanyi = MarsIfeanyi(_marsifeanyi);
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function stakeETH() external payable {
        if (msg.value == 0 && msg.value <= MINIMUM_AMOUNTETH)
            revert ZeroAmountNotAllowed(
                "You can't Stake Zero ETH and must be greater than MINIMUM_AMOUNTETH"
            );

        uint256 amountETH = msg.value;
        // Convert ETH to WETH
        IWETH(WETH).deposit{value: amountETH}();

        // Retrieve and update storage

        StakerData storage newStakerData = stakingData[msg.sender];

        uint _timeStaked = block.timestamp - stakingData[msg.sender].timeStaked;
        uint _rewards = stakingData[msg.sender].rewards;

        newStakerData.staker = msg.sender;
        newStakerData.amountStaked = msg.value;
        newStakerData.timeStaked = _timeStaked;
        newStakerData.rewards = _rewards;

        _calculateOnePercentAutoCompounding();

        _mintReceiptToken();

        emit ETHStaked(msg.sender, msg.value, block.timestamp);
    }

    function _calculateOnePercentAutoCompounding() internal {
        uint256 onePercent = (msg.value * 1) / 100;

        if (stakingData[msg.sender].isAutoCompounding) {
            stakingCompundingPool += onePercent;
            withAutoCompounding.push(msg.sender);
        } else {
            withAutoCompounding.push(msg.sender);
        }
    }

    function _mintReceiptToken() internal {
        // checks that balance of receiptToken, IER20(MarsIfeanyi.sol) is greater than msg.value;
        uint256 totalWETH = IWETH(WETH).balanceOf(address(this));
        uint256 receiptTokens = totalWETH == 0
            ? msg.value
            : msg.value.mul(marsIfeanyi.totalSupply()).div(totalWETH);
        marsIfeanyi.mint(msg.sender, receiptTokens);
    }

    function _calculateRewards(
        address _staker
    ) internal view returns (uint256) {
        StakerData storage newStakerData = stakingData[msg.sender];

        uint256 timeStaked = block.timestamp - newStakerData.timeStaked;

        // rewards = (time * rate * amount ) / Annual / 100%

        uint256 rewards = (timeStaked *
            14 *
            stakingData[_staker].amountStaked) /
            365 days /
            100;
        return rewards;
    }

    function autoCompound() external {
        for (uint256 i = 0; i < withAutoCompounding.length; i++) {
            address staker = withAutoCompounding[i];
            if (
                block.timestamp - stakingData[staker].timeStaked < 30 days ||
                stakingData[staker].rewards == 0
            ) {
                continue;
            }
            uint256 _rewards = _calculateRewards(staker);

            stakingData[staker].timeStaked = block.timestamp;
            uint256 rewards = stakingData[staker].rewards = 0;

            // checks balances
            uint256 initialBalance = IWETH(WETH).balanceOf(address(this));

            _swapRewardsToWeth(_rewards);

            uint256 AferBalance = IWETH(WETH).balanceOf(address(this));

            uint256 balanceDifference = AferBalance - initialBalance;

            marsIfeanyi.mint(staker, balanceDifference);

            uint256 _timeStaked = stakingData[staker].timeStaked;

            bool _isAutoCompounding = stakingData[staker].isAutoCompounding;

            StakerData storage newStakerData = stakingData[msg.sender];
            newStakerData.timeStaked = _timeStaked;
            newStakerData.isAutoCompounding = _isAutoCompounding;
            newStakerData.amountStaked = balanceDifference;
            newStakerData.rewards = rewards;
            newStakerData.staker = msg.sender;
        }
    }

    function _swapRewardsToWeth(uint256 _amountIn) internal {
        // swap dpt to weth

        IUniswapV2Router01 uniswapV2Router01 = IUniswapV2Router01(
            0xf164fC0Ec4E93095b804a4795bBe1e041497b92a
        );
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = WETH;

        uniswapV2Router01.swapExactTokensForTokens(
            _amountIn,
            0,
            path,
            address(this),
            block.timestamp + 1 days
        );
    }

    function withdrawStakedRewards(uint256 _amount) external {
        if (block.timestamp < stakingData[msg.sender].timeStaked + 7 days) {
            revert MinimumStakingTimeHasNotElapsed();
        }

        if (_amount <= 0) {
            revert CannotWithdrawZeroAmount();
        }
        uint256 rewards = _calculateRewards(msg.sender);

        if (rewards == 0 || rewards < _amount) {
            revert HeyInsufficientFunds();
        }

        IERC20(address(this)).transfer(msg.sender, _amount);

        emit StakedRewardsWithdrawed(msg.sender, _amount, block.timestamp);
    }

    function withdrawStakedTokensAndRewards() external {
        if (block.timestamp < stakingData[msg.sender].timeStaked + 7 days) {
            revert MinimumStakingTimeHasNotElapsed();
        }

        uint256 rewards = _calculateRewards(msg.sender);

        uint256 totalAmount = stakingData[msg.sender].amountStaked;

        delete stakingData[msg.sender];
        marsIfeanyi.burn(msg.sender, totalAmount);

        IWETH(WETH).withdraw(totalAmount);

        IERC20(address(this)).transfer(msg.sender, rewards);
        (bool Success, ) = payable(msg.sender).call{value: totalAmount}("");
        require(Success);

        emit StakedTokensAndRewardsWithdrawed(msg.sender, totalAmount, rewards);
    }
}
