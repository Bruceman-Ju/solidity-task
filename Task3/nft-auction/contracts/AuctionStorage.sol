// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

// for data storage
contract AuctionStorage {

    // 所有的拍卖
    address[] public auctions;

    // data for v1
    address public nftAddress;

    uint256 public tokenId;

    uint256 public price;
    
    // auction state: 0 -> NotPublished; 1 -> published; 2 -> End
    uint256 public status;
    
    address public nftOwner;
    
    address public bidder;
    
    uint256 public bidPrice; 
    
    uint256 public startTime;
    
    uint256 public endTime;

    // data added in v2
    // 0 -> ETH; 1 -> USDC
    uint256 public tokenType;

    address public tokenAddress;


}