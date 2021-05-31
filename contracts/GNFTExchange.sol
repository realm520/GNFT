// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IFeeKeeper.sol";

contract GNFTExchange is Ownable {
    using SafeMath for uint256;
    IFeeKeeper private feeContract;
    IERC721 private nftContract;
    IERC20 private usdtContract;
    mapping(address => mapping(uint256 => uint256)) public orders;
    mapping(uint256 => uint256[]) public tokenPrice;
    mapping(uint256 => address) public orderIndex;

    constructor() { } 

    function setFeeContract(IFeeKeeper _fee) public onlyOwner {
        feeContract = _fee;
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
        require(nftContract.ownerOf(_tokenid)==msg.sender, "sellNFT: Sender is not owner of given tokenid.");
        nftContract.transferFrom(msg.sender, address(this), _tokenid);
        require(nftContract.ownerOf(_tokenid)==address(this), "sellNFT: Transfer failed.");
        orders[msg.sender][_tokenid] = _price;
        orderIndex[_tokenid] = msg.sender;
    }

    function withdraw(uint256 _tokenid) external {
        require(orders[msg.sender][_tokenid]>0, "withdraw: No order for sender.");
        require(nftContract.ownerOf(_tokenid)==address(this), "withdraw: tokenid not in exchange.");
        nftContract.transferFrom(address(this), msg.sender, _tokenid);
        orders[msg.sender][_tokenid] = 0;
        orderIndex[_tokenid] = address(0);
    }

    function payProcess(address _seller, address _buyer, uint256 _tokenid, uint256 _price) internal {
        uint256 feeRate = feeContract.getTokenFeeRate(_tokenid);
        uint256 fee = feeRate.mul(_price).div(10000);
        uint256 feeKeeperBalance = usdtContract.balanceOf(address(feeContract));
        usdtContract.transferFrom(_buyer, address(feeContract), fee);
        require(usdtContract.balanceOf(address(feeContract))>=feeKeeperBalance+fee, "buyNFT: payment to fee fail.");
        feeContract.assignFee(fee);
        uint256 sellerBalance = usdtContract.balanceOf(_seller);
        usdtContract.transferFrom(_buyer, _seller, _price.sub(fee));
        require(usdtContract.balanceOf(_seller)>=sellerBalance.add(_price).sub(fee), "buyNFT: payment to seller fail.");
    }

    function buyNFT(uint256 _tokenid) external payable {
        address seller = orderIndex[_tokenid];
        require(seller!=address(0), "buyNFT: tokenid not on list.");
        uint256 price = orders[seller][_tokenid];
        payProcess(msg.sender, seller, _tokenid, price);
        nftContract.transferFrom(address(this), msg.sender, _tokenid);
        uint256[] storage pricesList = tokenPrice[_tokenid];
        if (pricesList.length == 0) {
            pricesList.push(price);
            pricesList.push(price);
        } else {
            uint256 totalValue = pricesList[0].mul(pricesList.length-1) + price;
            pricesList.push(price);
            pricesList[0] = totalValue.div(pricesList.length-1);
        }
    }

    function getPrice(uint256 _tokenid) public view returns (uint256) {
        uint256[] storage pricesList = tokenPrice[_tokenid];
        return pricesList[pricesList.length-1];
    }

    function checkPrice(address _from, address _to, uint256 _tokenid) external {
        uint256 permitPrice = getPrice(_tokenid);
        uint256 payerBalance = usdtContract.balanceOf(_to);
        require(payerBalance >= permitPrice, "checkPrice: insufficient balance.");
        payProcess(_to, _from, _tokenid, permitPrice);
    }
}

