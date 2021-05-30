// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFTExchange {
    function getPrice(uint256 _tokenId) external view returns (lastPrice, avgPrice);
    function checkPrice(address _from, uint256 _tokenId) external;
}

