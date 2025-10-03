// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./AuctionStorage.sol";

contract AuctionV2 is Initializable, OwnableUpgradeable, AuctionStorage {
    // 保持V1的所有事件
    event AuctionCreated(address indexed beneficiary, uint256 biddingTime);
    event BidIncreased(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);
    event MinBidIncrementChanged(uint256 newIncrement); // V2新增事件

    // V2新增状态变量（必须追加在最后）
    uint256 public minBidIncrement;

    // 禁用构造函数
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _beneficiary, uint256 _biddingTime) public initializer {
        __Ownable_init();
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
        ended = false;
        minBidIncrement = 0.01 ether; // 设置默认值
    }

    // 重写bid函数，添加新逻辑
    function bid() external payable {
        require(block.timestamp <= auctionEndTime, "Auction ended");
        require(msg.value >= highestBid + minBidIncrement, "Bid does not meet minimum increment");
        
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit BidIncreased(msg.sender, msg.value);
    }

    // V2新增功能
    function setMinBidIncrement(uint256 _increment) external onlyOwner {
        minBidIncrement = _increment;
        emit MinBidIncrementChanged(_increment);
    }

    // 保持V1其他函数不变
    function withdraw() external returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
        return true;
    }

    function auctionEnd() external {
        require(block.timestamp >= auctionEndTime, "Auction not ended");
        require(!ended, "Auction already ended");
        
        ended = true;
        payable(beneficiary).transfer(highestBid);
        
        emit AuctionEnded(highestBidder, highestBid);
    }
}