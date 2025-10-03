require("@chainlink/env-enc").config();
const { network } = require("hardhat");

const { DEVELOP_CHAINS, CONFIRMATIONS } = require("../helper-hardhat-config");
const { networks } = require("../hardhat.config");

module.exports = async ({ getNamedAccounts, deployments }) => {
    console.log("Deploying NFTAuction contract V1");

    const { firstAccount,secondAccount } = await getNamedAccounts();
    const { deploy } = deployments;

    let confirmations;

    // 本地环境
    if (DEVELOP_CHAINS.includes(network.name)) {
        confirmations = 0;
    } else {
        confirmations = CONFIRMATIONS;
    }

    

    await deploy("NFTAuctionV1",{
        contract: "NFTAuctionV1",
        from: firstAccount,
        log: true,
        waitConfirmations: confirmations
    });

    // const nftAuctionV1Proxy = await upgrades.deployProxy(factory, [],{ initializer: 'initialize' });
    // nftAuctionV1Proxy.waitForDeployment();
    // console.log("NFTAuctionV1Proxy",await nftAuctionV1Proxy.getAddress());

    // await deploy("nftAuctionV1Proxy",{
    //     from: firstAccount,
    //     log: true
    // });


    await deploy("MockNFT",{
        from: secondAccount,
        log: true
    });
    // It's recommended removing directory deployments instead of add args --reset when cmd deploying

    if (hre.network.config.chainId == networks.sepolia.chainId && process.env.ETHERSCAN_APIKEY) {
        await hre.run("verify:verify", {
            address: nftAuctionContract.address
        });
    } else {
        console.log("Environment is local, verification skipped")
    }
}

module.exports.tags = ["all", "nftauction_v1"];