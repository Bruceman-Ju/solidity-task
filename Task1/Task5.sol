// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MergeSortedArrays {
    function merge(int[] memory arr1, int[] memory arr2) public pure returns (int[] memory) {
        uint i = 0; // 指向arr1的指针
        uint j = 0; // 指向arr2的指针
        uint k = 0; // 指向结果数组的指针
        
        // 创建结果数组
        int[] memory result = new int[](arr1.length + arr2.length);
        
        // 合并两个数组
        while (i < arr1.length && j < arr2.length) {
            if (arr1[i] < arr2[j]) {
                result[k] = arr1[i];
                i++;
            } else {
                result[k] = arr2[j];
                j++;
            }
            k++;
        }
        
        // 将arr1的剩余元素添加到结果数组
        while (i < arr1.length) {
            result[k] = arr1[i];
            i++;
            k++;
        }
        
        // 将arr2的剩余元素添加到结果数组
        while (j < arr2.length) {
            result[k] = arr2[j];
            j++;
            k++;
        }
        
        return result;
    }
}
