// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 存储合约，定义固定的存储布局
contract AuctionStorage {
    // 存储布局必须固定，后续升级不能改变顺序或类型
    address public beneficiary;
    uint256 public auctionEndTime;
    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public pendingReturns;
    bool public ended;
}