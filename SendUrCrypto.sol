// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "/contracts/CustomERC20Token.sol";

contract SendUrCrypto is CustomERC20Token {

    string private key = "Jg68yfTkf54jIkEuf69K7";

    struct Code {
        uint256 code;
        uint256 value;
    }

    mapping(address => Code[]) private userCodes;

    constructor() CustomERC20Token("SUCRToken", "SUCR", 18, 100000) {}

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
        userCodes[msg.sender].push(
            Code(
                getRandom(msg.sender, msg.value), /// To generate a random code (cf. getRandom() function)
                msg.value));
    }

    function getCodeByUser() public view returns (Code[] memory) {
        return userCodes[msg.sender];
    }

/*
    function redeemCode(uint256 code) public {

        payable(msg.sender).transfer(codeToRedeem.value);
    }
*/
    
}