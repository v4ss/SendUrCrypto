// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "/contracts/CustomERC20Token.sol";

contract SendUrCrypto is CustomERC20Token {

    string private key = "Jg68yfTkf54jIkEuf69K7";

    struct Code {
        uint256 code;
        uint256 value;
    }

    struct UserCode {
        address userAddress;
        Code[] codes;
    }

    Code[] private code;
    UserCode[] private userCodes;

    constructor() CustomERC20Token("SUCRToken", "SUCR", 18, 100000) {}

    function findUserIndex(address userAddress) private view returns(uint256) {
        for(uint256 i = 0 ; i < userCodes.length ; i++) {
            if(userCodes[i].userAddress == userAddress) {
                return i;
            }
        }
        return type(uint256).max;
    }

    /**
     * @notice Get a random number using a key, user address, value sent by the user, timestamp, block number and block difficulty
     * @param "userAddress" the user address and "value" the value sent by the user when he executes the payable createCode function
     * @return uint256 random value
     */
    function getRandom(address userAddress, uint value) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            key,
            userAddress,
            value,
            block.timestamp,
            block.number,
            block.difficulty)));
    }

    /**
     * @notice Assigns a code corresponding to the value sent by the user. And stores them in the "userCodes" mapping.
     */
    function createCode() public payable {
        /// Push the new code with its value in the mapping
        
        Code memory newCode = Code(
            getRandom(msg.sender, msg.value),
            msg.value
        );

        UserCode memory newDeposit = UserCode(
            msg.sender,
            code
        );

        userCodes.push(newDeposit);

        code.pop();
    }


    function getCodeByUser() public view returns (UserCode memory) {
        uint256 index = findUserIndex(msg.sender);
        require(index != type(uint256).max, "User do not have code");
        return userCodes[index];
    }


    function redeemCode(uint256 code) public {
        for(uint256 i = 0 ; i < userCodes.length ; i++) {
            for(uint256 j = 0 ; j < userCodes[i].codes.length ; j++) {

                if(userCodes[i].codes[j].code == code) {
                    payable(msg.sender).transfer(userCodes[i].codes[j].value);
                }
            }
        }
    }

    
}