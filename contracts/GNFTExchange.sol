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
    IERC20 private usdtContract = "";
    mapping(address => uint256 => uint256) public orders;
    mapping(uint256 => address) pubic orderIndex;
    mapping(uint256 => uint256[]) public tokenPrice;

    constructor() { } 

    function setFeeContract(IFeeKeeper _fee) public onlyOwner {
        feeContract = _fee;
    }

    function setNftContract(IERC721 _nft) public onlyOwner {
        nftContract = _nft;
    }

    function sellNFT(uint256 _tokenid, uint256 _price) external {
        require(_nft.ownerOf(_tokenid)==msg.sender, "sellNFT: Sender is not owner of given tokenid.");
        nftContract.transferFrom(msg.sender, address(this), _tokenid);
        require(nftContract.ownerOf(_tokenid)==address(this), "sellNFT: Transfer failed.");
        orders[msg.sender][_tokenid] = _price;
        orderIndex[_tokenid] = msg.sender;
    }

    function withdraw(uint256 _tokenid) external {
        require(orders[msg.sender][_tokenid]>0, "withdraw: No order for sender.")
        require(nftContract.ownerOf(order.tokenid)==address(this), "withdraw: tokenid not in exchange.");
        _nft.transfer(msg.sender, _tokenid);
        orders[msg.sender][_tokenid] = 0;
        orderIndex[_tokenid] = address(0);
    }

    function payProcess(address _seller, address _buyer, uint256 _tokenId, uint256 _price) internal {
        uint256 price = orders[_seller][_tokenid];
        uint256 feeRate = feeContract.getTokenFeeRate(_tokenid);
        uint256 fee = feeRate.mul(price).div(10000);
        uint256 sellerBalance = usdtContract.balanceOf(_seller);
        uint256 feeKeeperBalance = usdtContract.balanceOf(feeContract);
        usdtContract.transferFrom(_buyer, feeContract, fee);
        require(usdtContract.balanceOf(feeContract)>=feeKeeperBalance+fee, "buyNFT: payment not enough.");
        feeContract.assignFee(fee);
        usdtContract.transferFrom(_buyer, _seller, price.sub(fee));
        require(usdtContract.balanceOf(_seller)>=sellerBalance.add(price).sub(fee), "buyNFT: payment not enough.");
    }

    function buyNFT(uint256 _tokenid) external payable {
        address seller = orderIndex[_tokenid];
        require(seller!=address(0), "buyNFT: tokenid not on list.")
        payProcess(msg.sender, seller, _tokenid);
        nftContract.transfer(msg.sender, _tokenid);
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

    function getPrice(uint256 _tokenId) public view returns (permitPrice) {
        uint256[] storage pricesList = tokenPrice[_tokenId];
        return priceList[pricesList.length-1];
    }

    function checkPrice(address _from, address _to, uint256 _tokenId) external {
        uint256 permitPrice = getPrice(_tokenId);
        uint256 payerBalance = usdtContract.balanceOf(_to);
        require(payerBalance >= permitPrice, "checkPrice: insufficient balance.");
        payProcess(_to, _from, _tokenid);
    }
}

