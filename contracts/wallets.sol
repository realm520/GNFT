//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract Wallet {
    address internal hotWallet = 0xc631DBE5b364033BbA5195bB2a5f9A987b6a18a0;

    constructor(address token) {
        // send all tokens from this contract to hotwallet
        IERC20(token).transfer(
            hotWallet,
            IERC20(token).balanceOf(address(this))
        );
        // selfdestruct to receive gas refund and reset nonce to 0
        selfdestruct(payable(address(0)));
    }
}

contract Fabric {
    function createContract(bytes memory code, uint256 salt) public {
        // get wallet init_code
        //bytes memory bytecode = type(Wallet).creationCode;
        assembly {
            let codeSize := mload(code) // get size of init_bytecode
            let newAddr := create2(
                0, // 0 wei
                add(code, 32), // the bytecode itself starts at the second slot. The first slot contains array length
                codeSize, // size of init_code
                salt // salt from function arguments
            )
        }
    }
}

