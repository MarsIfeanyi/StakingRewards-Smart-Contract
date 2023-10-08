// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MarsIfeanyi is ERC20 {
    constructor() ERC20("Mars Ifeanyi Receipt Token", "MIRT") {
        _mint(msg.sender, 1_0000_000_000e18);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
