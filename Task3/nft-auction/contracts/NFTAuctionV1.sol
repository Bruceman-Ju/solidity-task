// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./AuctionStorage.sol";

import "hardhat/console.sol";

// v1 版本拍卖合约只支持通过 ETH 代币拍卖
contract NFTAuctionV1 is AuctionStorage, Initializable{
    
    // initialize NFT auction contract
    function initialize() public initializer{
        status = 0;
    }
 
    // 用户上架 NFT
    function publish(address _nftAddress,uint256 _tokenId,uint256 _price,uint256 _duration) public auctionNotPublished{
        nftAddress = _nftAddress;
        tokenId = _tokenId;
        price = _price;
        status = 1;
        nftOwner = msg.sender;
        bidder = address(0);
        bidPrice = _price;
        startTime = block.timestamp;
        endTime = block.timestamp + _duration;
        IERC721(_nftAddress).safeTransferFrom(nftOwner,address(this),tokenId);
    }

    // ETH 竞价拍卖 NFT，只记录最高价
    function bidByETH() external payable auctionPublished{

        require(msg.value > bidPrice,"Bid price must be greater than current bid price");

        address _bidder = bidder;
        uint256 _bidPrice = bidPrice;

        tokenType = 1;
        bidder = msg.sender;
        bidPrice = msg.value;

        // 退还前一个出价者资产
        if (_bidder != address(0)){
            payable(_bidder).transfer(_bidPrice);
        }
    }

    // 结束拍卖，一手交钱，一手交货
    function endAuction() external onlyAuctionOwner auctionPublished {
        
        require(block.timestamp < endTime, "Auction end");
        address _bidder = bidder;
        address _nftOwner = nftOwner;
        uint256 _bidPrice = bidPrice;
        // 先更新状态，再交互，避免重入风险。
        status = 1;
        nftOwner = bidder;
        price = bidPrice;
        bidder = address(0);
        // 转移 NFT

        IERC721(nftAddress).safeTransferFrom(address(this), _bidder, tokenId);
        
        payable(_nftOwner).transfer(_bidPrice);
    }

    modifier onlyAuctionOwner {
        require(nftOwner == msg.sender,"Only auction owner can operation");
        _;
    }

    modifier auctionNotPublished {
        require(status == 0 , "Auction is already published");
        _;
    }

    modifier auctionPublished {
        require(status == 1 , "Auction is not published Or End");
        _;
    }

    event ERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    );

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        emit ERC721Received(operator, from, tokenId, data);
        return this.onERC721Received.selector;
    }
}