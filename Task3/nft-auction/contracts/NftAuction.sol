// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract NftAuction {
    
    struct Auction {
        address seller;
        uint256 duration;
        uint256 startPrice;
        bool ended;
        address highestBidder;
        uint256 highestBid;
        uint256 startTime;
        address nftContract;
        uint256 tokenId;
    }

    mapping (uint256 => Auction) public auctions;

    uint256 public nextAcutionId;

    address public admin;

    constructor(){
        admin = msg.sender;
    }

    function createAuction(uint256 _duration, uint256 _startPrice, address _nftAddress, uint256 _tokenId) public {
        auctions[nextAcutionId] = Auction({
            seller: msg.sender,
            duration: _duration,
            startPrice: _startPrice,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            startTime: block.timestamp,
            nftContract:_nftAddress,
            tokenId:_tokenId
        });
        nextAcutionId++; 
    }

    function placeBid(uint256 _auctionId) external payable{

        Auction storage auction = auctions[_auctionId];

        require(!auction.ended && auction.startTime+auction.duration>block.timestamp,"Current Auction ended");
        require(msg.value>auction.highestBid && msg.value>auction.startPrice,"Bid price must greater than current price");

        if(auction.highestBidder != address(0)){
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;

    }

    function show() external view returns(address,uint256){
        return (admin,nextAcutionId);
    }


}