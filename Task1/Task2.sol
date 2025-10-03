// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
反转字符串 (Reverse String)
题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"
*/
contract StrReverse {
    function reverse(
        string memory strVar
    ) external pure returns (string memory) {
        bytes memory _origin = bytes(strVar);

        uint len = _origin.length;

        bytes memory result = new bytes(len);

        for (uint i = 0; i < len; i++) {
            result[i] = _origin[len - i - 1];
        }
        return string(result);
    }

    function vote(string memory candidate) external pure returns (bool) {
        require(bytes(candidate).length > 0,"candidate address can not be null");
        candidate = "hello world";
        return true;
    }
}
