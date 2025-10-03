require("@chainlink/env-enc").config();
const { getNamedAccounts, network } = require("hardhat");
const { DEVELOP_CHAINS, NETWORK_CONFIG, CONFIRMATIONS,ETH_INITIAL_PRICE,USDC_INITIAL_PRICE} = require("../helper-hardhat-config");
const { networks } = require("../hardhat.config");
module.exports = async ({ getNamedAccounts, deployments }) => {
    console.log("Deploying NFTAuction contract V2");
    const { firstAccount,secondAccount } = await getNamedAccounts();
    const { deploy } = deployments;

    let confirmations;

    // 本地环境
    if (DEVELOP_CHAINS.includes(network.name)) {
        confirmations = 0;
    } else {
        confirmations = CONFIRMATIONS;
    }

    await deploy("Mock_DataFeed_ETH",{
        contract: "MockV3Aggregator",
        args: [18,ETH_INITIAL_PRICE],
        from: firstAccount,
        log: true
    });
    await deploy("Mock_DataFeed_USDC",{
        contract: "MockV3Aggregator",
        args: [6,USDC_INITIAL_PRICE],
        from: firstAccount,
        log: true
    });

    await deploy("NFTAuctionV2", {
        contract: "NFTAuctionV2",
        from: firstAccount,
        log: true,
        waitConfirmations: confirmations
    });

    await deploy("MockNFT",{
        from: secondAccount,
        log: true
    });

    await deploy("MockUSDC",{
        from: secondAccount,
        log: true
    });
    // It's recommended removing directory deployments instead of add args --reset when cmd deploying

    // if (hre.network.config.chainId == networks.sepolia.chainId && process.env.ETHERSCAN_APIKEY) {
    //     await hre.run("verify:verify", {
    //         address: nftAuctionContract.address
    //     });
    // } else {
    //     console.log("Environment is local, verification skipped")
    // }
}

module.exports.tags = ["all", "nftauction_v2"];