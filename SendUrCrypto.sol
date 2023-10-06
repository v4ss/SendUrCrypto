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
        uint256 codesCount;
        mapping(uint256 => Code) codes;

    }

    UserCode[] private userCodes;

    constructor() CustomERC20Token("SUCRToken", "SUCR", 18, 100000) {}

    /**
     * @notice Find the index of the current user in the users array
     * @param userAddress value of the current user address
     * @return i value of the index
     */
    function findUserIndex(address userAddress) private view returns(uint256) {
        for(uint256 i = 0 ; i < userCodes.length ; i++) {
            if(userCodes[i].userAddress == userAddress) {
                return i;
            }
        }
        /// Impossible value for indicate that the user isn't register in the array
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
        /// To find the index user, if he exists
        uint256 index = findUserIndex(msg.sender);

        /// He doesn't exist
        if(index == type(uint256).max) {
            UserCode storage newDeposit = userCodes[userCodes.length];
            newDeposit.userAddress = msg.sender;
            newDeposit.codes[0].code = getRandom(msg.sender, msg.value);
            newDeposit.codesCount = 1;
        }
        /// He exists, we add him his new code
        else {
            UserCode storage newDeposit = userCodes[index];
            uint256 count = userCodes[index].codesCount;
            newDeposit.codes[count].code = getRandom(msg.sender, msg.value);
            newDeposit.codesCount = count++;
        }
    }

    /**
     * @notice Get all the codes of the current user
     * @return Code[], an array of struct Code contains the codes and their values
     */
    function getCodeByUser() public view returns (Code[] memory) {
        uint256 index = findUserIndex(msg.sender);
        require(index != type(uint256).max, "User do not have code");
        Code[] memory codes;
        for(uint256 i = 0 ; i < userCodes[index].codesCount ; i++) {
            codes[i].code = userCodes[index].codes[i].code;
            codes[i].value = userCodes[index].codes[i].value;
        }
        return codes;
    }

    /**
     * @notice Transfers the value of the code, if it exists
     * @param code uint256
     */
    function redeemCode(uint256 code) public {
        /// To browse all the users
        for(uint256 i = 0 ; i < userCodes.length ; i++) {
            /// To browse all the users's codes
            for(uint256 j = 0 ; j < userCodes[i].codesCount ; j++) {
                /// If the code exists, transfers the value to the user
                if(userCodes[i].codes[j].code == code) {
                    payable(msg.sender).transfer(userCodes[i].codes[j].value);
                }
            }
        }
    }

    
}