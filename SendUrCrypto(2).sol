// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "/contracts/CustomERC20Token.sol";

contract SendUrCrypto is CustomERC20Token {

    address payable public smartContractAddress;

    string private key = "Jg68yfTkf54jIkEuf69K7";

    struct Code {
        uint256 code;
        uint256 value;
    }

    struct Deposit {
        address userAddress;
        Code[] codes;
    }

    Deposit[] private deposits;

    constructor() CustomERC20Token("SUCRToken", "SUCR", 18, 100000) {
        smartContractAddress = payable(address(this));
    }

    function findUserIndex(address userAddress) private view returns(uint256) {
        for(uint256 i = 0 ; i < deposits.length ; i++) {
            if(deposits[i].userAddress == userAddress) {
                return i;
            }
        }
        return type(uint256).max;
    }

    function getRandom(address user, uint value) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(key, user, value, block.timestamp, block.number, block.difficulty)));
    }

    function createCode() public payable {
        uint256 index = findUserIndex(msg.sender);
        uint256 random = getRandom(msg.sender, msg.value);
        
        if(index != type(uint256).max) {
            uint256 codeNumber = deposits[index].codes.length;

            deposits[index].codes[codeNumber].code = random;
            deposits[index].codes[codeNumber].value = msg.value;
        }
        else {
            Code[] memory newCode;
            newCode[0] = Code(random, msg.value);
            Deposit memory newDeposit = Deposit(msg.sender, newCode);

            deposits.push(newDeposit);
        }
    }

    function getCodeByUser() public view returns (Deposit memory info) {
        uint256 index = findUserIndex(msg.sender);
        require(index != type(uint256).max, "User do not have code");
        return deposits[index];
    }

    
}