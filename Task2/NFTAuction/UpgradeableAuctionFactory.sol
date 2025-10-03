// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AuctionProxy.sol";
import "./AuctionV1.sol";
import "./AuctionV2.sol";

contract UpgradeableAuctionFactory {
    address public currentImplementation;
    address[] public allAuctions;

    // 版本控制
    mapping(address => address) public proxyToImplementation;
    
    event AuctionCreated(address indexed proxy, address indexed implementation, address beneficiary);
    event AuctionUpgraded(address indexed proxy, address indexed oldImpl, address newImpl);
    
    constructor() {
        // 初始部署V1版本
        currentImplementation = address(new AuctionV1());
    }
    
    function createAuction(address _beneficiary, uint256 _biddingTime) external returns (address) {
        // 创建代理合约
        AuctionProxy proxy = new AuctionProxy(currentImplementation);
        
        // 初始化拍卖合约
        AuctionV1(address(proxy)).initialize(_beneficiary, _biddingTime);
        
        allAuctions.push(address(proxy));
        proxyToImplementation[address(proxy)] = currentImplementation;
        
        emit AuctionCreated(address(proxy), currentImplementation, _beneficiary);
        return address(proxy);
    }
    
    function upgradeAuction(address proxyAddress, address newImplementation) external {
        require(proxyToImplementation[proxyAddress] != address(0), "Not a valid auction");
        
        AuctionProxy proxy = AuctionProxy(proxyAddress);
        address oldImplementation = proxyToImplementation[proxyAddress];
        
        // 执行升级
        proxy.upgradeTo(newImplementation);
        proxyToImplementation[proxyAddress] = newImplementation;
        
        emit AuctionUpgraded(proxyAddress, oldImplementation, newImplementation);
    }
    
    function upgradeFactory(address newImplementation) external {
        currentImplementation = newImplementation;
    }
    
    function getAuctionsCount() external view returns (uint256) {
        return allAuctions.length;
    }
    
    function getAuctionInfo(uint256 index) external view returns (address proxy, address implementation) {
        require(index < allAuctions.length, "Index out of bounds");
        proxy = allAuctions[index];
        implementation = proxyToImplementation[proxy];
    }
}