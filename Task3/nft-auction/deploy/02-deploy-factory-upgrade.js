require("@chainlink/env-enc").config();
const { getNamedAccounts, network } = require("hardhat");
const { DEVELOP_CHAINS, NETWORK_CONFIG, CONFIRMATIONS,ETH_INITIAL_PRICE,USDC_INITIAL_PRICE} = require("../helper-hardhat-config");
const { networks } = require("../hardhat.config");
module.exports = async ({ getNamedAccounts, deployments }) => {
    console.log("Deploying NFTAuction factory contract V1 and V2");

    const { firstAccount,secondAccount } = await getNamedAccounts();
    const { deploy } = deployments;

    let confirmations;

    // 本地环境
    if (DEVELOP_CHAINS.includes(network.name)) {
        confirmations = 0;
    } else {
        confirmations = CONFIRMATIONS;
    }

    // await deploy("NFTAuctionFactoryV1",{
    //     contract: "NFTAuctionFactoryV1",
    //     from: firstAccount,
    //     log: true
    // });
    
    // await deploy("NFTAuctionFactoryV2",{
    //     contract: "NFTAuctionFactoryV2",
    //     from: firstAccount,
    //     log: true
    // });

    // It's recommended removing directory deployments instead of add args --reset when cmd deploying

    if (hre.network.config.chainId == networks.sepolia.chainId && process.env.ETHERSCAN_APIKEY) {
        await hre.run("verify:verify", {
            address: nftAuctionContract.address
        });
    } else {
        console.log("Environment is local, verification skipped")
    }
}

module.exports.tags = ["all", "nftauction_v2"];