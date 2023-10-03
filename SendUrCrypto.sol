// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "/contracts/CustomERC20Token.sol";

contract SendUrCrypto is CustomERC20Token {

    address payable public smartContractAddress;

    struct Deposit {
        address userAddress;
        uint256 code;
        uint256 value;
    }

    Deposit[] private deposits;

    constructor() CustomERC20Token("SUCRToken", "SUCR", 18, 100000) {
        smartContractAddress = payable(address(this));
    }

    function getRandom() private returns (uint256) {}

    function getCode() public payable returns (uint256) {
        Deposit memory newDeposit;
        newDeposit.userAddress = msg.sender;
        newDeposit.code = getRandom();
        newDeposit.value = msg.value;

        deposits.push(newDeposit);

        return newDeposit.code;
    }

    function sendMoney() public payable {}
}