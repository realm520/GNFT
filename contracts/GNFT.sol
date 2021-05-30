// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/INFTExchange.sol";

contract GArtItem is ERC721, ERC721Enumerable, Ownable {
    Counters.Counter private _tokenIdTracker;
    INFTExchange private _platform;

    constructor(INFTExchange platform) ERC721("GArtItem", "GNFT") {
        _platform = platform;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        // Don't check tax for address(0).
        if (address(0) == from || address(0) == to) {
            return;
        }
        require(from == address(_platform) , "_beforeTokenTransfer: transfer from platform is required.");
        uint256 permitPrice = _platform.checkPrice(from, to, tokenId);
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "https://tokenid.gnft.com/";
    }

    function mint(address to) public onlyOwner {
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

}

