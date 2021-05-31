// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    constructor() ERC20("USDT", "USDT") {
        uint256 totalSupply = 100000000000 * 10 ** 18;
        _mint(msg.sender, totalSupply);
    }
}

