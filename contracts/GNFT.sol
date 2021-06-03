// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/INFTExchange.sol";
import "./interfaces/IFeeKeeper.sol";
import "hardhat/console.sol";

contract GNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    INFTExchange private _platform;
    IFeeKeeper private _fee;

    constructor(INFTExchange platform, IFeeKeeper fee) ERC721("GArtItem", "GNFT") {
        _platform = platform;
        _fee = fee;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        // Don't check tax for address(0).
        if (address(0) == from || address(0) == to) {
            return;
        }
        //require(from == address(_platform) , "_beforeTokenTransfer: transfer from platform is required.");
        _platform.checkPrice(from, to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://tokenid.gnft.com/";
    }

    function mint(address to, address author, uint256 ratio) public onlyOwner {
        uint256 currentId = _tokenIdTracker.current();
        _mint(to, currentId);
        _tokenIdTracker.increment();
        _fee.setAuthorTokenFee(address(this), currentId, author, ratio);
    }

}

