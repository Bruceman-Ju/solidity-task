// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// 罗马数字转整数
contract RomanToInteger {
    mapping(bytes1 => uint256) private romanValues;

    constructor() {
        romanValues[bytes1('I')] = 1;
        romanValues[bytes1('V')] = 5;
        romanValues[bytes1('X')] = 10;
        romanValues[bytes1('L')] = 50;
        romanValues[bytes1('C')] = 100;
        romanValues[bytes1('D')] = 500;
        romanValues[bytes1('M')] = 1000;
    }

    function romanToInt(string calldata s) external view returns (uint256) {
        bytes memory romanBytes = bytes(s);
        uint256 length = romanBytes.length;
        require(length > 0, "Empty string");

        uint256 result = 0;
        uint256 prevValue = 0;

        for (uint256 i = length; i > 0; i--) {
            // Convert `bytes1` explicitly (instead of `char`)
            bytes1 currentChar = romanBytes[i - 1];
            uint256 currentValue = romanValues[currentChar];
            require(currentValue > 0, "Invalid Roman character");

            if (currentValue < prevValue) {
                result -= currentValue;
            } else {
                result += currentValue;
            }
            prevValue = currentValue;
        }
        return result;
    }
}