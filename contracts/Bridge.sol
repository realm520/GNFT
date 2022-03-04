// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Bridge is Ownable, Pausable, ReentrancyGuard {
    address public operator1;
    address public operator2;
    struct TokenOut {
        address token;
        address to;
        uint256 value;
        int approveCount;
    }
    mapping(uint256 => TokenOut) outs;
    struct TokenIn {
        address token;
        address from;
        uint256 value;
    }
    mapping(uint256 => TokenIn) ins;
    uint256 inLength;

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

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function withdraw(address _token) external onlyOwner {
        if (address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        if (tokenBalance >0) {
            IERC20(_token).transfer(msg.sender, tokenBalance);
        }
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function sendToken(uint256 _fromIndex, address _token, address _to, uint256 _value) public whenNotPaused nonReentrant {
        require(operator1 == msg.sender || operator2 == msg.sender, "Invalid opeartor");
        require(_value > 0, "Invalid value");
        TokenOut storage out = outs[_fromIndex];
        if (out.value <= 0) {
            int approval;
            if (msg.sender == operator1) {
                approval = 1;
            } else {
                approval = 2;
            }
            outs[_fromIndex] = TokenOut({
                token: _token,
                to: _to,
                value: _value,
                approveCount: approval
            });
        } else {
            if ((msg.sender == operator1 && out.approveCount == 2) 
                || (msg.sender == operator2 && out.approveCount == 1)) {
                require(_value == out.value && out.token == _token, "Out record mismatch");
                out.approveCount = 3;
                IERC20(_token).transfer(_to, _value);
            } else {
                revert("Invalid approval count");
            }
        }
    }

    function sendEther(uint256 _fromIndex, address payable _to, uint256 _value) public whenNotPaused nonReentrant {
        require(operator1 == msg.sender || operator2 == msg.sender, "Invalid operator");
        require(_value > 0, "Invalid value");
        TokenOut storage out = outs[_fromIndex];
        if (out.value <= 0) {
            int approval;
            if (msg.sender == operator1) {
                approval = 1;
            } else {
                approval = 2;
            }
            outs[_fromIndex] = TokenOut({
                token: address(0),
                to: _to,
                value: _value,
                approveCount: approval
            });
        } else {
            if ((msg.sender == operator1 && out.approveCount == 2) 
                || (msg.sender == operator2 && out.approveCount == 1)) {
                require(_value == out.value && out.token == address(0), "Out record mismatch");
                out.approveCount = 3;
                (bool sent, bytes memory data) = _to.call{value: _value}("");
                require(sent, "Failed to send Ether");
            } else {
                revert("Invalid approval count");
            }
        }
    }

    function depositEther() payable public whenNotPaused {
        if (msg.value > 0) {
            TokenIn storage inRec = ins[inLength];
            inRec.token = address(0);
            inRec.from = msg.sender;
            inRec.value = msg.value;
            inLength += 1;
        }
    }

    function depositToken(address _token, uint256 _value) payable public whenNotPaused nonReentrant {
        if (_value > 0) {
            uint256 balance1 = IERC20(_token).balanceOf(address(this));
            IERC20(_token).transferFrom(msg.sender, address(this), _value);
            uint256 balance2 = IERC20(_token).balanceOf(address(this));
            require((balance2 - balance1) == _value, "Transfer token in failure");
            TokenIn storage inRec = ins[inLength];
            inRec.token = _token;
            inRec.from = msg.sender;
            inRec.value = _value;
            inLength += 1;
        }
    }

    function getIn(uint256 offset) public view returns (TokenIn memory result) {
        require(inLength > offset || offset < 0, "Invalid offset");
        result = ins[offset];
    }

    function getOut(uint256 fromHash) public view returns (TokenOut memory result) {
        return outs[fromHash];
    }

    function getInLength() public view returns (uint256 result) {
        result = inLength;
    }
}
