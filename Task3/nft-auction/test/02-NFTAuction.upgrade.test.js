const { deployments, ethers, getNamedAccounts,upgrades } = require("hardhat");
const { expect } = require("chai");

describe("NFT auction Tests For upgrade", async function () {
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

        mockNFTSecondAccount = await ethers.getContract("MockNFT", secondAccount);

        mockUSDC2 = await ethers.getContract("MockUSDC", secondAccount);
        mockUSDC3 = await ethers.getContract("MockUSDC", thirdAccount);
        mockUSDC4 = await ethers.getContract("MockUSDC", fourthAccount);
        
        ethDataFeed = await ethers.getContract("Mock_DataFeed_ETH",firstAccount);
        usdcDataFeed = await ethers.getContract("Mock_DataFeed_USDC",firstAccount);

    });

    // 升级 NFTAuctionFactory
    it("Upgrade Test: data can be read after NFTAuction contract upgrading from V1 to V2",async function(){
        
        const FactoryV1 = await ethers.getContractFactory("NFTAuctionFactoryV1");

        const factoryProxy = await upgrades.deployProxy(FactoryV1,[],{ initializer: 'initialize' });
        factoryProxy.waitForDeployment();
        
        await factoryProxy.createAuction();

        const auctionByNFTAuctionV1 = await factoryProxy.auctions(0);

        const FactoryV2 = await ethers.getContractFactory("NFTAuctionFactoryV2");

        const factoryCurrent = await upgrades.upgradeProxy(factoryProxy, FactoryV2);
        await factoryCurrent.waitForDeployment();

        console.log("FactoryV2Proxy",await factoryCurrent.getAddress());

        console.log(await factoryCurrent.auctions(0));

        factoryCurrent.createAuction();

        expect(auctionByNFTAuctionV1).to.equal(await factoryCurrent.auctions(0));
        
        
    });
});