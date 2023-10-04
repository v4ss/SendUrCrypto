// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "/contracts/CustomERC20Token.sol";

contract SendUrCrypto is CustomERC20Token {

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

    constructor() CustomERC20Token("SUCRToken", "SUCR", 18, 100000) {}

    /**
     * @notice Find the index of the current user in the deposits array
     * @param userAddress value of the current user address
     * @return i value of the index
     */
    function findUserIndex(address userAddress) private view returns(uint256) {
        for(uint256 i = 0 ; i < deposits.length ; i++) {
            if(deposits[i].userAddress == userAddress) {
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
        return uint256(keccak256(abi.encodePacked(key, userAddress, value, block.timestamp, block.number, block.difficulty)));
    }

    /**
     * @notice Assigns a code corresponding to the value sent by the user. And stores them in the "deposits" array.
     */
    function createCode() public payable {
        uint256 j = 0;
        while(j == 0) {
            /// To find out if the user already has/had codes, and if yes, know his index in the array (cf. findUserIndex() function)
            uint256 index = findUserIndex(msg.sender);
            
            /// If he already has code(s) or just his address is recorded in the array
            if(index != type(uint256).max) {
                /// Generates his random code (cf. getRandom() function)
                uint256 random = getRandom(msg.sender, msg.value);

                /// And push in his array a new raw for his new code corresponding to the value
                deposits[index].codes.push(Code(random, msg.value));

                /// Increments "j" to leave the loop
                j++;
            }
            /// If the user doesn't have code yet
            else {
                /// We push a new root raw for his identity and go back to the beginning to assigns him his code
                Deposit memory newDeposit;
                newDeposit.userAddress = msg.sender;

                deposits.push(newDeposit);
            }
        }
    }

    function getCodeByUser() public view returns (Deposit memory info) {
        uint256 index = findUserIndex(msg.sender);
        require(index != type(uint256).max, "User do not have code");
        return deposits[index];
    }

    
}