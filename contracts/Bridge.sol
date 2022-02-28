// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Bridge is Ownable, Pausable, ReentrancyGuard {
    address internal operator1;
    address internal operator2;
    struct TokenOut {
        address to;
        uint256 value;
        int approveCount;
    }
    TokenOut[] outs;
    int outsSize;
    struct TokenIn {
        address from;
        uint256 value;
    }
    TokenIn[] ins;

    constructor() {
    }

    function setOperator(address _operator, uint index) public onlyOwner {
        if (index == 1) {
            operator1 = _operator;
        } else if (index == 2) {
            operator2 = _operator;
        } else {
            revert("Invalid index");
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function sendToken(address  _token, address _to, uint256 _value) public whenNotPaused nonReentrant {
        require(operator1 == msg.sender || operator2 == msg.sender, "Invalid opeartor");
        IERC20(_token).transfer(_to, _value);
    }

    function sendEther(address _to, uint256 _value) public whenNotPaused nonReentrant {
        require(operator1 == msg.sender || operator2 == msg.sender, "Invalid opeartor");
        
    }

    function deposit(address _token, uint256 _value) payable public whenNotPaused nonReentrant {
        if (msg.value > 0) {
            ins.push(TokenIn({
                from: msg.sender,
                value: msg.value
            }));
        }
        if (_value > 0) {
            uint256 balance1 = IERC20(_token).balanceOf(address(this));
            IERC20(_token).transferFrom(msg.sender, address(this), _value);
            uint256 balance2 = IERC20(_token).balanceOf(address(this));
            require((balance2 - balance1) == _value, "Transfer token in failure");
            ins.push(TokenIn({
                from: msg.sender,
                value: _value
            }));
        }
    }

    function getIns(uint256 offset) public view returns (TokenIn memory result) {
        require(ins.length > offset || offset < 0, "Invalid offset");
        result = ins[offset];
    }
}
