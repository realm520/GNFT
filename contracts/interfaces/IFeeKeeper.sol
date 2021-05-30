// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFeeKeeper {
    function getTokenFeeRate(uint256 _tokenId) external view returns (uint256 feeRate);
    function assignFee(uint256 _fee) external;
}


