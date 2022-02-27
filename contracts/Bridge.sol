// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bridge is Ownable {
    string internal admin;
    int public status;
    address internal operator;

    constructor() {
        status = 1;
    }

    function setOperator(address _operator) public onlyOwner {
        operator = _operator;
    }

    function control(int s) public onlyOwner {
        assert(s == 0 || s == 1);
        status = s;
    }

    function sendToken(address  _token, address _to, int _value) public {
        assert(operator == msg.sender && status == 1);
        // console.log(_token, _to, _value);
    }

    function deposit(address _token, int value) payable public {
    }
}
