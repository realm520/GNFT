// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFTExchange {
    function getPrice(uint256 _tokenid) external view returns (uint256[2] memory);
    function checkPrice(address _from, address _to, uint256 _tokenid) external;
}

