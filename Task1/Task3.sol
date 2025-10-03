// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 罗马数字转整数
contract IntegerToRoman {
    // 定义数值和对应的罗马符号，按从大到小顺序排列
    uint256[] private values;
    string[] private symbols;

    constructor() {
        values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
        symbols = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"];
    }

    /**
     * @dev 将整数转换为罗马数字
     * @param num 输入的整数，范围应在1到3999之间
     * @return 返回对应的罗马数字字符串
     */
    function intToRoman(uint256 num) public view returns (string memory) {
        require(num > 0 && num < 4000, "Number must be between 1 and 3999");
        string memory roman;
        uint256 remaining = num;

        // 遍历所有预定义的符号值
        for (uint256 i = 0; i < values.length; i++) {
            // 当剩余值大于当前符号值时，重复拼接该符号并减去对应值
            while (remaining >= values[i]) {
                roman = string(abi.encodePacked(roman, symbols[i]));
                remaining -= values[i];
            }
            if (remaining == 0) break;
        }
        return roman;
    }
}