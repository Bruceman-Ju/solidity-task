const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { expect } = require("chai");

describe("NFT auction Tests For V1", function () {
    let firstAccount;
    let secondAccount;
    let thirdAccount;
    let fourthAccount;
    let mockNFTSecondAccount;
    
    let ipfsUrl = "ipfs://0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238";

    beforeEach(async function () {
        await deployments.fixture(["all"]);

        firstAccount = (await getNamedAccounts()).firstAccount;
        secondAccount = (await getNamedAccounts()).secondAccount;
        thirdAccount = (await getNamedAccounts()).thirdAccount;
        fourthAccount = (await getNamedAccounts()).fourthAccount;

        // getContract 用某一个账户连接一个已经部署的合约。
        nftAuctionByFirstAccount = await ethers.getContract("NFTAuctionV1", firstAccount);        
        nftAuctionBySecondAccount = await ethers.getContract("NFTAuctionV1", secondAccount);
        nftAuctionByThirdAccount = await ethers.getContract("NFTAuctionV1", thirdAccount);
        nftAuctionByFourthAccount = await ethers.getContract("NFTAuctionV1",fourthAccount);

        const mockNFTDeployment = await deployments.get("MockNFT");
        mockNFTSecondAccount = await ethers.getContract("MockNFT", secondAccount);
        
    });

    it("Test function initialize: successfully called",async function(){
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize();
        expect(await nftAuctionByFirstAccount.status()).to.be.eq(0);
    });
    
    it("Test function publish: revert with message NFT is already published", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize();
        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
        const tokenId = await mockNFTSecondAccount.tokenId();
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, 1, 3600 * 1000);
        await expect(nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, 1, 3600 * 1000)).to.be.revertedWith("Auction is already published");
    });

    it("Test function publish: successfully called",async function () { 
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize();

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
        const tokenId = await mockNFTSecondAccount.tokenId();

        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("1"), 3600 * 1000);

        expect(await nftAuctionBySecondAccount.tokenId()).to.be.eq(tokenId);
        expect(await nftAuctionBySecondAccount.nftAddress()).to.be.eq(mockNFTSecondAccount);
        expect(await nftAuctionBySecondAccount.price()).to.be.eq(ethers.parseEther("1"));
        expect(await nftAuctionBySecondAccount.bidPrice()).to.be.eq(ethers.parseEther("1"));
    });

    it("Test function bidByETH: revert with message Auction is not published Or End", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize();

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
                    
        await expect(nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("0.1")})).to.be.revertedWith("Auction is not published Or End");
    });

    it("Test function bidByETH: revert with message Bid price must be greater than current bid price", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();
        await nftAuctionByFirstAccount.initialize();

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("1"), 3600 * 1000);
        await expect(nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("0.1")})).to.be.revertedWith("Bid price must be greater than current bid price");
    });

    it("Test function bidByETH: transfer ETH to account with lower bid price", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize();

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);

        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("10"), 3600 * 1000);

        await nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("11")});
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("11"));

        await nftAuctionByFourthAccount.bidByETH({value: ethers.parseEther("13")});
        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("13"));
    });

    it("Test function endAuction: revert with message Only auction owner can operation", async function () {
        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize();

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);

        const tokenId = await mockNFTSecondAccount.tokenId();
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, tokenId);
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, tokenId, ethers.parseEther("10"), 3600 * 1000);
        
        await nftAuctionByThirdAccount.bidByETH({value: ethers.parseEther("11")});

        await expect(nftAuctionByThirdAccount.endAuction()).to.be.revertedWith("Only auction owner can operation");

        await nftAuctionByFourthAccount.bidByETH({value: ethers.parseEther("13")});

        expect(await ethers.provider.getBalance(nftAuctionByThirdAccount)).to.be.equal(ethers.parseEther("13"));
    });

    it("Test function endAuction: successfully called", async function () {

        await nftAuctionByFirstAccount.waitForDeployment();

        await nftAuctionByFirstAccount.initialize();

        await mockNFTSecondAccount.waitForDeployment();

        await mockNFTSecondAccount.mintNFT(ipfsUrl);
        expect(await mockNFTSecondAccount.ownerOf(await mockNFTSecondAccount.tokenId())).to.be.eq(secondAccount);
        
        await mockNFTSecondAccount.approve(nftAuctionBySecondAccount, (await mockNFTSecondAccount.tokenId()));
        await nftAuctionBySecondAccount.publish(mockNFTSecondAccount, await mockNFTSecondAccount.tokenId(), ethers.parseEther("10"), 3600 * 1000);
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