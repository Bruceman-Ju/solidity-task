// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./NFTAuctionV2.sol";

import "./AuctionStorage.sol";

import "hardhat/console.sol";

// factory contract
// understand factory contract by architecture instead of logic
contract NFTAuctionFactoryV2 is AuctionStorage, Initializable{

    function initialize() public initializer{

    }

    // create NFT auction and save proxy and implementation
    function createAuction() external returns (address){
        
        NFTAuctionV2 auctionV2 = new NFTAuctionV2();

        auctions.push(address(auctionV2));

        emit AuctionCreated(address(auctionV2));

        return address(auctionV2);
    }

    event AuctionCreated(address indexed implementation);
    event FactoryUpgraded(address indexed implementation);
}
