// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFeeKeeper {
    function getTokenFeeRate(uint256 _tokenId) external view returns (uint256 feeRate);
    function assignFee(uint256 _tokenid, uint256 _price) external;
    function setAuthorTokenFee(address _nft, uint256 _tokenId, address _author, uint256 _ratio) external;
    function getFeeToken() external view returns (address);
}


