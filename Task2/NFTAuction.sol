// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./AuctionStorage.sol";

import "hardhat/console.sol";

contract NFTAuction is AuctionStorage,ERC721URIStorage,Initializable{

    mapping (TokenType => AggregatorV3Interface) public dataFeeds;

    IERC20 public usdcToken;

    Initializable(address _mintOwner,address _usdcAddr,address _dataFeedETH,address _dataFeedUSDC) ERC721("NftAuction", "NAT"){
        dataFeeds[TokenType.ETH] = AggregatorV3Interface(_dataFeedETH);
        dataFeeds[TokenType.USDC] = AggregatorV3Interface(_dataFeedUSDC);
        usdcToken = IERC20(_usdcAddr);
        owner = _mintOwner;
    }

    // 用户 mint NFT
    function mintNFT(string memory _tokenURI, uint256 _price, uint8 _tokenType) onlyAuctionOwner external returns (uint256) {

        tokenId++;
        _mint(msg.sender, tokenId); 
        _setTokenURI(tokenId, _tokenURI);

        tokenId = tokenId;
        price = _price;
        status = AuctionState.NotPublished;
        owner = msg.sender;
        bidder = address(0);
        bidPrice = _price;
        tokenType = TokenType(_tokenType);
        startTime = block.timestamp;
        endTime = block.timestamp + 1 days;
        console.log("tokenId: ", tokenId);
        return tokenId;
    }
 
    // 用户发布 NFT
    function publish() external onlyAuctionOwner auctionNotPublished{
        status = AuctionState.Published;
    }

    // ETH 竞价拍卖 NFT，只记录最高价
    function bidByETH() external payable auctionPublished{

        require(_bidPriceGreaterThenCurrentPrice(TokenType.ETH,msg.value),"Bid price must be greater than current bid price");

        // 退还前一个出价者资产
        if (bidder != address(0)){
            if(tokenType == TokenType.ETH){
                payable(bidder).transfer(bidPrice);
            }
            if(tokenType == TokenType.USDC){
                // 有问题
                usdcToken.approve(bidder,bidPrice);
                usdcToken.transferFrom(address(this),bidder,bidPrice);
                usdcToken.approve(bidder,0);
            }
        }
        bidPrice = msg.value;
        tokenType = TokenType.ETH;
        bidder = msg.sender;
    }

    // USDC 竞价拍卖 NFT，只记录最高价
    function bidByUSDC(uint256 _price) external auctionPublished{
        
        require(_bidPriceGreaterThenCurrentPrice(TokenType.USDC,_price),"Bid price must be greater than current bid price");
        
        // 退还前一个出价者资产
        if (bidder != address(0)){
            if(tokenType == TokenType.ETH){
                payable(bidder).transfer(bidPrice);
            }
            if(tokenType == TokenType.USDC){
                // 有问题
                usdcToken.approve(bidder,bidPrice);
                usdcToken.transferFrom(address(this),bidder,bidPrice);
                usdcToken.approve(bidder,0);
            }
        }

        usdcToken.approve(msg.sender, _price);  
        usdcToken.transferFrom(msg.sender, address(this), _price);

        bidPrice = _price;
        tokenType = TokenType.USDC;
        bidder = msg.sender;
    }


    // 结束拍卖，一手交钱，一手交货
    function endAuction() external onlyAuctionOwner auctionPublished {
        
        // 转移 NFT
        approve(bidder,tokenId);
        transferFrom(owner, bidder, tokenId);

        if(tokenType == TokenType.ETH){
            payable(owner).transfer(bidPrice);
        }

        if(tokenType == TokenType.USDC){
            usdcToken.approve(owner, bidPrice);
            usdcToken.transferFrom(bidder,owner,bidPrice);
        }

        status = AuctionState.NotPublished;
        owner = bidder;
        bidder = address(0);
        price = bidPrice;
    }

    modifier onlyAuctionOwner {
        require(owner == msg.sender,"Only auction owner can operation");
        _;
    }

    modifier auctionNotPublished {
        require(status == AuctionState.NotPublished, "NFT is already published");
        _;
    }

    modifier auctionPublished {
        require(status == AuctionState.Published, "NFT is not published");
        _;
    }

    function _convertETH2USD(uint256 ethAmount) public view returns(uint256){
        return ethAmount * uint256(getChainlinkDataFeedLatestAnswer(dataFeeds[TokenType.ETH])) / 10 ** 18;
    }

    // token / 精度 * dataFeed
    function _convertUSDC2USD(uint256 usdcAmount) public view returns(uint256){
        return usdcAmount * uint256(getChainlinkDataFeedLatestAnswer(dataFeeds[TokenType.USDC]));
    }

    // 0.001 * 3000 = 300000000 USD
    // 1 USDC 100000000 -> 99994412 USD
    function _bidPriceGreaterThenCurrentPrice
        (
            TokenType _bidTokenType,
            uint256 _bidPrice
        ) public returns(bool){
        if(_bidTokenType == tokenType){
            return _bidPrice > bidPrice;
        }else{
            _bidPrice = _bidTokenType == TokenType.USDC ? _convertUSDC2USD(_bidPrice) : _convertETH2USD(_bidPrice);
            bidPrice = tokenType == TokenType.USDC ? _convertUSDC2USD(bidPrice) : _convertETH2USD(bidPrice);
            return _bidPrice > bidPrice;
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
}