module.exports = {
    ETH_INITIAL_PRICE: 412592170000,
    USDC_INITIAL_PRICE: 99963769,
    CONFIRMATIONS:5,
    // hardhat 是命令行运行对应的网络，一次部署之后，下次就消失了，用户开发。
    // local 是启动之后，可以进行合约交互的网络。
    DEVELOP_CHAINS: ["hardhat","local"],
    NETWORK_CONFIG: {
        11155111:{
            ethDataFeed: "0x694AA1769357215DE4FAC081bf1f309aDC325306",
            usdcDataFeed: "0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E",
        }
    }
}