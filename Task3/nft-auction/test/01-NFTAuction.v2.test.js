const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { expect } = require("chai");

describe("NFT auction Tests For V2", async function () {
    let firstAccount;
    let secondAccount;
    let thirdAccount;
    let fourthAccount;
    let mockNFTSecondAccount;
    let ethDataFeed;
    let usdcDataFeed;
    
    let ipfsUrl = "ipfs://0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238";


    beforeEach(async function () {
        await deployments.fixture(["all"]);
        firstAccount = (await getNamedAccounts()).firstAccount;
        secondAccount = (await getNamedAccounts()).secondAccount;
        thirdAccount = (await getNamedAccounts()).thirdAccount;
        fourthAccount = (await getNamedAccounts()).fourthAccount;

        nftAuctionByFirstAccount = await ethers.getContract("NFTAuctionV2", firstAccount);
        nftAuctionBySecondAccount = await ethers.getContract("NFTAuctionV2", secondAccount);
        nftAuctionByThirdAccount = await ethers.getContract("NFTAuctionV2", thirdAccount);
        nftAuctionByFourthAccount = await ethers.getContract("NFTAuctionV2",fourthAccount);

        mockNFTSecondAccount = await ethers.getContract("MockNFT", secondAccount);

        mockUSDC2 = await ethers.getContract("MockUSDC", secondAccount);
        mockUSDC3 = await ethers.getContract("MockUSDC", thirdAccount);
        mockUSDC4 = await ethers.getContract("MockUSDC", fourthAccount);
        
        ethDataFeed = await ethers.getContract("Mock_DataFeed_ETH",firstAccount);
        usdcDataFeed = await ethers.getContract("Mock_DataFeed_USDC",firstAccount);
    });

    it("Test function initialize: successfully called",async function(){
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);
        expect(await nftAuctionByFirstAccount.status()).to.be.eq(0);
        expect(await nftAuctionByFirstAccount.dataFeeds(0)).to.be.eq(ethDataFeed);
        expect(await nftAuctionByFirstAccount.dataFeeds(1)).to.be.eq(usdcDataFeed);
    });
    
    it("Test function publish: revert with message Auction is already published", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();
        await mockNFTSecondAccount.mintNFT(ipfsUrl);
        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, 1, 3600 * 1000,0);
        await expect(nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, 1, 3600 * 1000,0)).to.be.revertedWith("Auction is already published");
    });

    it("Test function publish: successfully called",async function () { 

        // 1. 获取最新的区块号
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        
        // 2. 根据区块号获取区块详细信息
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        
        // 3. 从区块信息中提取时间戳（单位为秒）
        const timestamp = latestBlock.timestamp;

        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
        const tokenId = await mockNFTSecondAccount.tokenId();

        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("1"), 3600 * 1000,0);

        expect(await nftAuctionBySecondAccount.nftAddress()).to.be.eq(mockNFTSecondAccount);
        expect(await nftAuctionBySecondAccount.tokenId()).to.be.eq(tokenId);
        expect(await nftAuctionBySecondAccount.price()).to.be.eq(ethers.parseEther("1"));
        expect(await nftAuctionBySecondAccount.status()).to.be.eq(1);
        expect(await nftAuctionBySecondAccount.nftOwner()).to.be.eq(secondAccount);
        expect(await nftAuctionBySecondAccount.bidder()).to.be.eq(ethers.ZeroAddress);
        expect(await nftAuctionBySecondAccount.bidPrice()).to.be.eq(ethers.parseEther("1"));
        expect(3600 * 1000).to.be.eq((await nftAuctionBySecondAccount.endTime())-(await nftAuctionBySecondAccount.startTime()));
        expect(await nftAuctionBySecondAccount.endTime()).to.be.greaterThan(timestamp);
        expect(await nftAuctionBySecondAccount.tokenType()).to.be.eq(0);

    });

    it("Test function bidByETH: revert with message Auction is not published Or End", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
                    
        await expect(nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("0.1")})).to.be.revertedWith("Auction is not published Or End");
    });

    it("Test function bidByETH: revert with message Bid price must be greater than current bid price", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("1"), 3600 * 1000,0);
        await expect(nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("0.1")})).to.be.revertedWith("Bid price must be greater than current bid price");
    });

    

    // publish by USDC, bid by USDC, bid by USDC, refund USDC

    // publish by USDC, bid by ETH, bid by ETH, refund ETH

    // publish by USDC, bid by USDC, bid by ETH, refund USDC

    it("Test function bidByETH: publish 10 ETH, account1 bid 11 ETH, account2 bid 13 ETH, refund 11 ETH to account1", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);

        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("10"), 3600 * 1000,0);

        await nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("11")});
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("11"));

        await nftAuctionByFourthAccount.bidByETH({value: ethers.parseEther("13")});
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("13"));
    });

    it("Test function bidByETH: publish 1 ETH, account1 bid 1.1 ETH, account2 bid 5100000000 USDC, refund 1.1 ETH to account1", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);

        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("1"), 3600 * 1000,0);

        await nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("1.1")});
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("1.1"));

        await mockUSDC4.waitForDeployment();
        
        await mockUSDC4.mint1W();
        await mockUSDC4.approve(nftAuctionByFourthAccount, 5100000000);
        await nftAuctionByFourthAccount.bidByUSDC(5100000000,mockUSDC4);

        expect(await mockUSDC4.balanceOf(nftAuctionByFourthAccount)).to.be.equal(5100000000);
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(0);
        expect(await mockUSDC3.balanceOf(fourthAccount)).to.be.equal(4900000000);
    });

    it("Test function bidByETH: publish 1 ETH, account1 bid 4600000000 USDC, account2 bid 5100000000 USDC, refund 4600000000 ETH to account1", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);

        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("1"), 3600 * 1000,0);
        
        await mockUSDC3.waitForDeployment();
        await mockUSDC3.mint1W();
        await mockUSDC3.approve(nftAuctionByThirdAccount, 4600000000);
        await nftAuctionByThirdAccount.bidByUSDC(4600000000, mockUSDC3);
        expect(await mockUSDC3.balanceOf(nftAuctionByThirdAccount)).to.be.equal(4600000000);
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(0);

        await mockUSDC4.waitForDeployment();
        await mockUSDC4.mint1W();
        await mockUSDC4.approve(nftAuctionByFourthAccount, 5100000000);
        await nftAuctionByFourthAccount.bidByUSDC(5100000000,mockUSDC4);

        expect(await mockUSDC4.balanceOf(nftAuctionByFourthAccount)).to.be.equal(5100000000);
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(0);
        expect(await mockUSDC3.balanceOf(thirdAccount)).to.be.equal(10000000000);
    });

    it("Test function bidByETH: publish 1 ETH, account1 bid 4600000000 USDC, account2 bid 2 ETH, refund 4600000000 USDC to account1", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);

        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, 3000000000, 3600 * 1000,1);
        
        await mockUSDC3.waitForDeployment();
        await mockUSDC3.mint1W();
        await mockUSDC3.approve(nftAuctionByThirdAccount, 4600000000);
        await nftAuctionByThirdAccount.bidByUSDC(4600000000, mockUSDC3);

        expect(await mockUSDC3.balanceOf(nftAuctionByThirdAccount)).to.be.equal(4600000000);
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(0);

        await nftAuctionByFourthAccount.bidByETH({value: ethers.parseEther("2")});

        expect(await mockUSDC4.balanceOf(nftAuctionByFourthAccount)).to.be.equal(0);
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("2"));
        expect(await mockUSDC3.balanceOf(thirdAccount)).to.be.equal(10000000000);
    });

    // publish by USDC, bid by ETH, bid by USDC, refund ETH
    it("Test function bidByETH: publish 4000000000 USDC, account1 bid 1 ETH, account2 bid 4500000000 USDC, refund 1 ETH to account1", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);

        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, 4000000000, 3600 * 1000,1);
        
        await nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("1")});

        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("1"));

        mockUSDC4.waitForDeployment();
        mockUSDC4.mint1W();
        mockUSDC4.approve(nftAuctionByFourthAccount, 4500000000);
        await nftAuctionByFourthAccount.bidByUSDC(4500000000,mockUSDC4);

        expect(await mockUSDC4.balanceOf(nftAuctionByFourthAccount)).to.be.equal(4500000000);
        expect(await ethers.provider.getBalance(nftAuctionByFourthAccount)).to.be.equal(0);
    });


    it("Test function endAuction: revert with message Only auction owner can operation", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);

        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("10"), 3600 * 1000,0);
        
        await nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("11")});

        await expect(nftAuctionByThirdAccount.endAuction()).to.be.revertedWith("Only auction owner can operation");

        await nftAuctionByFourthAccount.bidByETH({value: ethers.parseEther("13")});

        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("13"));
    });

    it("Test function endAuction: successfully called", async function () {

        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize(ethDataFeed,usdcDataFeed);

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
        expect(await mockNFTSecondAccount.ownerOf(await mockNFTSecondAccount.tokenId())).to.be.eq(secondAccount);
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, (await mockNFTSecondAccount.tokenId()));
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, await mockNFTSecondAccount.tokenId(), ethers.parseEther("10"), 3600 * 1000,0);
        expect(await mockNFTSecondAccount.ownerOf(await mockNFTSecondAccount.tokenId())).to.be.eq(nftAuctionByFirstAccount);

        await nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("11")});
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("11"));
        expect(await nftAuctionByThirdAccount.bidder()).to.be.equal(thirdAccount);

        await nftAuctionByFourthAccount.bidByETH({value: ethers.parseEther("13")});
        expect(await ethers.provider.getBalance(nftAuctionByFirstAccount)).to.be.equal(ethers.parseEther("13"));
        expect(await nftAuctionByFourthAccount.bidder()).to.be.equal(fourthAccount);

        await nftAuctionBySecondAccount.endAuction();
        expect(await mockNFTSecondAccount.ownerOf(await mockNFTSecondAccount.tokenId())).to.be.eq(fourthAccount);
    });
});