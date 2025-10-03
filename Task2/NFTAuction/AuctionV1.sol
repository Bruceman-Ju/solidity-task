// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./AuctionStorage.sol";

contract AuctionV1 is Initializable, OwnableUpgradeable, AuctionStorage {
    event AuctionCreated(address indexed beneficiary, uint256 biddingTime);
    event BidIncreased(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);

    // 禁用构造函数，使用初始化函数
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _beneficiary, uint256 _biddingTime) public initializer {
        __Ownable_init();
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
        ended = false;
        
        emit AuctionCreated(_beneficiary, _biddingTime);
    }

    function bid() external payable {
        require(block.timestamp <= auctionEndTime, "Auction ended");
        require(msg.value > highestBid, "Bid not high enough");
        
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit BidIncreased(msg.sender, msg.value);
    }

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