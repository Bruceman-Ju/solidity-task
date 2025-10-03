// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract UpgradeStorage {

    // 当前实现地址
    address public currentImplementation;

    // contract version control for upgrade
    // proxy -> Implementation
    mapping(address => address) public proxyToImplementation;
}