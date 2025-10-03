// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./AuctionStorage.sol";

import "hardhat/console.sol";

contract NFTAuctionV2 is AuctionStorage, Initializable {


    // 0 -> ETH, 1 -> USDC
    mapping (uint256 => AggregatorV3Interface) public dataFeeds;

    // initialize NFT auction contract
    function initialize(address _eth2usd,address _usdc2usd) public initializer{
        dataFeeds[0] = AggregatorV3Interface(_eth2usd);
        dataFeeds[1] = AggregatorV3Interface(_usdc2usd);
        status = 0;
    }

    // 用户上架 NFT
    function publish(address _nftAddress,uint256 _tokenId,uint256 _price,uint256 _duration,uint256 _tokenType) auctionNotPublished public{
        nftAddress = _nftAddress;
        tokenId = _tokenId;
        price = _price;
        status = 1;
        nftOwner = msg.sender;
        bidder = address(0);
        bidPrice = _price;
        startTime = block.timestamp;
        endTime = block.timestamp + _duration;
        tokenType = _tokenType;
        IERC721(_nftAddress).safeTransferFrom(nftOwner,address(this),tokenId);
    }

    // ETH 竞价拍卖 NFT，只记录最高价
    function bidByETH() external payable auctionPublished{

        require(_bidPriceGreaterThenCurrentPrice(0,msg.value),"Bid price must be greater than current bid price");

        // 上一次状态，用于业务处理，
        address _bidder = bidder;
        uint256 _bidPrice = bidPrice;
        uint256 _tokenType = tokenType;

        // 更新状态，防止重入
        bidPrice = msg.value;
        tokenType = 0;
        bidder = msg.sender;

        // 退还前一个出价者资产
        if (_bidder != address(0)){
            if(_tokenType == 0){
                payable(_bidder).transfer(_bidPrice);
            }
            if(_tokenType == 1){
                IERC20(tokenAddress).transfer(_bidder,_bidPrice);
            }
        }
    }

    // USDC 竞价拍卖 NFT，只记录最高价
    function bidByUSDC(uint256 _price,address _usdcAddress) external auctionPublished{
        
        require(_bidPriceGreaterThenCurrentPrice(1,_price),"Bid price must be greater than current bid price");
        
        address _bidder = bidder;
        uint256 _tokenType = tokenType;
        uint256 _bidPrice = bidPrice;

        bidPrice = _price;
        tokenType = 1;
        bidder = msg.sender;
        tokenAddress = _usdcAddress;

        // 退还前一个出价者资产
        if (_bidder != address(0)){
            if(_tokenType == 0){
                payable(_bidder).transfer(_bidPrice);
            }
            if(_tokenType == 1){
                // 合约转账給账户用 transfer 而不是 tranferFrom
                IERC20(tokenAddress).transfer(_bidder,_bidPrice);
            }
        }

        IERC20(_usdcAddress).transferFrom(msg.sender,address(this),_price);
    }


    // 结束拍卖，一手交钱，一手交货
    function endAuction() external onlyAuctionOwner auctionPublished {
        
        address _bidder = bidder;
        address _nftOwner = nftOwner;
        uint256 _bidPrice = price;
        uint256 _tokenType = tokenType;

        status = 0;
        nftOwner = bidder;
        bidder = address(0);
        price = bidPrice;

        // 转移 NFT
        IERC721(nftAddress).safeTransferFrom(address(this), _bidder, tokenId);

        if(_tokenType == 0){
            payable(_nftOwner).transfer(_bidPrice);
        }

        if(_tokenType == 1){
            IERC20(tokenAddress).transferFrom(_bidder,_nftOwner,_bidPrice);
        }
    }

    modifier onlyAuctionOwner {
        require(nftOwner == msg.sender,"Only auction owner can operation");
        _;
    }

    modifier auctionNotPublished {
        require(status == 0, "Auction is already published");
        _;
    }

    modifier auctionPublished {
        require(status == 1, "Auction is not published Or End");
        _;
    }

    function _convertETH2USD(uint256 ethAmount) public view returns(uint256){
        return ethAmount * uint256(getChainlinkDataFeedLatestAnswer(dataFeeds[0])) / 10 ** 18;
    }

    // token / 精度 * dataFeed
    function _convertUSDC2USD(uint256 usdcAmount) public view returns(uint256){
        return usdcAmount * uint256(getChainlinkDataFeedLatestAnswer(dataFeeds[1])) / 10 ** 6;
    }

    // 写函数之前一定要区分 view pure，否则钱少了都不知道。
    function _bidPriceGreaterThenCurrentPrice
        (
            uint256 _bidTokenType,
            uint256 _bidPrice
        ) public view returns(bool){
        if(_bidTokenType == tokenType){
            return _bidPrice > bidPrice;
        }else{
            uint256 convertedBidPrice = _bidTokenType == 1 ? _convertUSDC2USD(_bidPrice) : _convertETH2USD(_bidPrice);
            uint256 convertedCurrentPrice = tokenType == 1 ? _convertUSDC2USD(bidPrice) : _convertETH2USD(bidPrice);
            return convertedBidPrice > convertedCurrentPrice;
        }
    }

    function getChainlinkDataFeedLatestAnswer(AggregatorV3Interface _dataFeed) public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = _dataFeed.latestRoundData();
        return answer;
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