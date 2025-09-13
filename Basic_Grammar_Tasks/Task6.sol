// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BinarySearch {
    function binarySearch(int[] memory arr, int target) public pure returns (int) {
        if (arr.length == 0) {
            return -1;
        }
        
        uint left = 0;
        uint right = arr.length - 1;
        
        while (left <= right) {
            // 防止溢出，使用left + (right - left) / 2
            uint mid = left + (right - left) / 2;
            
            if (arr[mid] == target) {
                return int(mid); // 找到目标，返回索引
            } else if (arr[mid] < target) {
                left = mid + 1; // 目标在右半部分
            } else {
                // 防止下溢
                if (mid == 0) {
                    break;
                }
                right = mid - 1; // 目标在左半部分
            }
        }
        
        return -1; // 未找到目标
    }
}