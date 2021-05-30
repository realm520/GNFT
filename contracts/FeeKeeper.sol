// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FeeKeeper is Ownable {
    using SafeMath for uint256;

    struct FeeKeeperInfo {
        address keeper;
        uint256 ratio;
    }

    IERC20 feeToken;
    mapping(uint256 => uint256) tokenRate;
    mapping(address => uint256) feeAssignment;
    FeeKeeperInfo[] public feeInfo;
    uint256 feeInfoLength;
    uint256 remainFeeRatio = 10000;
    

    constructor(IERC20 _feeToken) {
        feeToken = _feeToken;
    }

    function getTokenFeeRate(uint256 _tokenId) external view returns (uint256 feeRate) {
        return tokenRate[_tokenId];
    }

    function setTokenFeeRate(uint256 _tokenId, uint256 _feeRate) public onlyOwner {
        require(_feeRate > 0, "setTokenFeeRate: invalid fee rate.");
        tokenRate[_tokenId] = _feeRate;
    }

    function addFeeKeeper(address _keeper, uint256 _ratio) public onlyOwner {
        require(_keeper != address(0), "addFeeKeeper: invalid keeper.");
        require(_ratio <= remainFeeRatio, "addFeeKeeper: invalid ratio.");
        bool keeperExist = false;
        for (uint i=0; i<feeInfoLength; i++) {
            if (feeInfo[i].keeper == _keeper) {
                feeInfo[i].ratio = _ratio;
                keeperExist = true;
                break;
            }
        }
        if (!keeperExist) {
            FeeKeeperInfo memory newKeeper = FeeKeeperInfo(_keeper, _ratio);
            feeInfo.push(newKeeper);
            feeInfoLength = feeInfoLength + 1;
        }
    }

    function removeKeeper(address _keeper) public onlyOwner {
        bool keeperExist = false;
        for (uint i=0; i<feeInfoLength; i++) {
            if (feeInfo[i].keeper == _keeper) {
                feeInfo[i].keeper = feeInfo[feeInfoLength-1].keeper;
                feeInfo[i].ratio = feeInfo[feeInfoLength-1].ratio;
                feeInfoLength = feeInfoLength - 1;
                break;
            }
        }
    }

    function assignFee(uint256 _fee) external {
        require(_fee > 0, "assignFee: invalid fee.");
        for (uint i=0; i<feeInfoLength; i++) {
            uint256 fee = _fee.mul(100000000).mul(feeInfo[i].ratio).div(10000).div(1000000000);
            if (fee > 0) {
                feeAssignment[feeInfo[i].keeper] = feeAssignment[feeInfo[i].keeper] + fee;
            }
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



