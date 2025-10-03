// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./NFTAuctionV1.sol";

import "./AuctionStorage.sol";

import "hardhat/console.sol";

// factory contract
// understand factory contract by architecture instead of logic
contract NFTAuctionFactoryV1 is AuctionStorage, Initializable{

    function initialize() public initializer{
    }

    // create NFT auction and save proxy and implementation
    function createAuction() external returns (address){
        
        NFTAuctionV1 auctionV1 = new NFTAuctionV1();

        auctionV1.initialize();

        auctions.push(address(auctionV1));

        emit AuctionCreated(address(auctionV1));

        return address(auctionV1);
    }

    event AuctionCreated(address indexed implementation);
    event FactoryUpgraded(address indexed implementation);
}
