// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";

contract FeeKeeper is Ownable {
    using SafeMath for uint256;

    struct FeeKeeperInfo {
        address keeper;
        uint256 ratio;
    }

    IERC20 public feeToken;
    mapping(address => uint256) feeAssignment;
    FeeKeeperInfo[] public feeInfo;
    mapping(uint256 => FeeKeeperInfo) authorTokenFee;
    uint256 feeInfoLength;
    uint256 defaultTokenRate = 500;
    

    constructor(IERC20 _feeToken) {
        feeToken = _feeToken;
    }

    function getFeeToken() external view returns (address) {
        return address(feeToken);
    }

    function getTokenFeeRate(uint256 _tokenId) external view returns (uint256) {
        uint256 rate = authorTokenFee[_tokenId].ratio;
        for (uint i=0; i<feeInfoLength; i++) {
            rate = rate + feeInfo[i].ratio;
        }
        return rate;
    }

    function checkFee(address _user) public view returns(uint256 fee) {
        return feeAssignment[_user];
    }

    function setAuthorTokenFee(address _nft, uint256 _tokenId, address _author, uint256 _ratio) external {
        require(IERC721(_nft).ownerOf(_tokenId) != address(0), "setAuthorTokenFee: invalid tokenid.");
        require(_author != address(0), "setAuthorTokenFee: invalid author address.");
        require(_ratio < 10000, "setAuthorTokenFee: invalid author ratio.");
        FeeKeeperInfo storage author = authorTokenFee[_tokenId];
        require(author.keeper == address(0), "setAuthorTokenFee: change author fee not permitted.");
        author.keeper = _author;
        author.ratio = _ratio;
    }

    function addFeeKeeper(address _keeper, uint256 _ratio) public onlyOwner {
        require(_keeper != address(0), "addFeeKeeper: invalid keeper.");
        require(_ratio < 10000, "addFeeKeeper: invalid ratio.");
        bool keeperExist = false;
        uint256 totalRatio = 0;
        for (uint i=0; i<feeInfoLength; i++) {
            if (feeInfo[i].keeper == _keeper) {
                feeInfo[i].ratio = _ratio;
                keeperExist = true;
                totalRatio = totalRatio + _ratio;
            } else {
                totalRatio = totalRatio + feeInfo[i].ratio;
            }
        }
        if (!keeperExist) {
            FeeKeeperInfo memory newKeeper = FeeKeeperInfo(_keeper, _ratio);
            feeInfo.push(newKeeper);
            feeInfoLength = feeInfoLength + 1;
            totalRatio = totalRatio + _ratio;
        }
        require(totalRatio < 10000, "addFeeKeeper: invalid total ratio.");
    }

    function removeKeeper(address _keeper) public onlyOwner {
        for (uint i=0; i<feeInfoLength; i++) {
            if (feeInfo[i].keeper == _keeper) {
                feeInfo[i].keeper = feeInfo[feeInfoLength-1].keeper;
                feeInfo[i].ratio = feeInfo[feeInfoLength-1].ratio;
                feeInfoLength = feeInfoLength - 1;
                break;
            }
        }
    }

    function assignFee(uint256 _tokenid, uint256 _price) external {
        require(_price > 0, "assignFee: invalid fee and price.");
        for (uint i=0; i<feeInfoLength; i++) {
            uint256 fee = _price.mul(100000000).mul(feeInfo[i].ratio).div(10000).div(100000000);
            if (fee > 0) {
                feeAssignment[feeInfo[i].keeper] = feeAssignment[feeInfo[i].keeper] + fee;
            }
        }
        FeeKeeperInfo memory author = authorTokenFee[_tokenid];
        if (author.ratio > 0) {
            feeAssignment[author.keeper] = feeAssignment[author.keeper] + _price.mul(100000000).mul(author.ratio).div(10000).div(100000000);
        }
    }

    function withdraw(address _to) public {
        uint256 fee = feeAssignment[msg.sender];
        require(fee > 0, "withdraw: zero fee.");
        require(feeToken.balanceOf(address(this)) > fee, "withdraw: insufficient fee.");
        feeToken.transfer(_to, fee);
    }

    function clear(address _to) public onlyOwner {
        bool canClear = true;
        uint256 remain = feeToken.balanceOf(address(this));
        for (uint i=0; i<feeInfoLength; i++) {
            //remain = reamin - feeAssignment[feeInfo[i].keeper];
            if (feeAssignment[feeInfo[i].keeper] > 0) {
                canClear = false;
                break;
            }
        }
        if (canClear) {
            feeToken.transfer(_to, remain);
        }
    }
}



