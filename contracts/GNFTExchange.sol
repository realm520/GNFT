// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IFeeKeeper.sol";
import "hardhat/console.sol";

contract GNFTExchange is Ownable {
    using SafeMath for uint256;
    IFeeKeeper private feeContract;
    IERC721 private nftContract;
    IERC20 private usdtContract;
    mapping(address => mapping(uint256 => uint256)) public orders;
    mapping(uint256 => uint256[2]) public tokenPrice;
    mapping(uint256 => uint) public tokenStatus; // 0 - normal, 1 - exchange processing
    mapping(uint256 => address) public orderIndex;

    constructor() { } 

    function setFeeContract(IFeeKeeper _fee) public onlyOwner {
        feeContract = _fee;
        usdtContract = IERC20(feeContract.getFeeToken());
    }

    function setNftContract(IERC721 _nft) public onlyOwner {
        nftContract = _nft;
    }

    function getSellPrice(uint256 _tokenid) public view returns (uint256) {
        address seller = orderIndex[_tokenid];
        if (seller == address(0)) {
            return 0;
        } else {
            return orders[seller][_tokenid];
        }
    }

    function sellNFT(uint256 _tokenid, uint256 _price) external {
        require(_price > 0, "sellNFT: Price cannot be 0.");
        uint256[2] memory permitPrice = getPrice(_tokenid);
        require(_price >= permitPrice[0], "sellNFT: invalid price < last fee.");
        require(nftContract.ownerOf(_tokenid)==msg.sender, "sellNFT: Sender is not owner of given tokenid.");
        tokenStatus[_tokenid] = 1;
        nftContract.transferFrom(msg.sender, address(this), _tokenid);
        require(nftContract.ownerOf(_tokenid)==address(this), "sellNFT: Transfer failed.");
        orders[msg.sender][_tokenid] = _price;
        orderIndex[_tokenid] = msg.sender;
        tokenStatus[_tokenid] = 0;
    }

    function withdraw(uint256 _tokenid) external {
        require(orders[msg.sender][_tokenid]>0, "withdraw: No order for sender.");
        require(nftContract.ownerOf(_tokenid)==address(this), "withdraw: tokenid not in exchange.");
        tokenStatus[_tokenid] = 1;
        nftContract.transferFrom(address(this), msg.sender, _tokenid);
        orders[msg.sender][_tokenid] = 0;
        orderIndex[_tokenid] = address(0);
        tokenStatus[_tokenid] = 0;
    }

    function buyNFT(uint256 _tokenid) external payable {
        address seller = orderIndex[_tokenid];
        require(seller!=address(0), "buyNFT: tokenid not on list.");
        nftContract.transferFrom(address(this), msg.sender, _tokenid);
        orders[msg.sender][_tokenid] = 0;
        orderIndex[_tokenid] = address(0);
    }

    function getPrice(uint256 _tokenid) public view returns (uint256[2] memory) {
        uint256[2] memory pricesList = tokenPrice[_tokenid];
        return pricesList;
    }

    function checkPrice(address _from, address _to, uint256 _tokenid) external {
        if (tokenStatus[_tokenid] == 1) {
            return;
        }
        uint256[2] storage permitPrice = tokenPrice[_tokenid];
        uint256 payerBalance = usdtContract.balanceOf(_to);
        address seller = _from;
        if (seller == address(this)) {
            seller = orderIndex[_tokenid];
        }
        uint256 price = orders[seller][_tokenid];
        require(payerBalance >= permitPrice[0], "checkPrice: insufficient balance for last fee.");
        require(payerBalance >= price, "checkPrice: insufficient balance for price.");
        uint256 fee = permitPrice[0];
        if (price > permitPrice[1]) {
            uint256 feeRate = feeContract.getTokenFeeRate(_tokenid);
            fee = feeRate.mul(price).div(10000);
            feeContract.assignFee(_tokenid, price);
        } else {
            feeContract.assignFee(_tokenid, permitPrice[1]);
        }
        //uint256 feeBalance = usdtContract.balanceOf(address(feeContract));
        usdtContract.transferFrom(_to, address(feeContract), fee);
        //require(usdtContract.balanceOf(address(feeContract))>=feeBalance+fee, "checkPrice: payment to fee fail.");
        if (price > permitPrice[0]) {
            uint256 sellerBalance = usdtContract.balanceOf(seller);
            usdtContract.transferFrom(_to, seller, price.sub(fee));
            require(usdtContract.balanceOf(seller)==sellerBalance.add(price).sub(fee), "checkPrice: payment to seller fail.");
        }
        if (price > permitPrice[1]) {
            permitPrice[0] = fee;
            permitPrice[1] = price;
        }
    }
}

