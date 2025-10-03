require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@nomicfoundation/hardhat-ethers");
require("hardhat-deploy-ethers");
require("@chainlink/env-enc").config();
require("@openzeppelin/hardhat-upgrades");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      logging: "verbose"
    },
    sepolia: {
      url: process.env.SEPOLIA_URL,
      accounts: [
        // process.env.PRIVATE_KEY1,
        // process.env.PRIVATE_KEY2,
        // process.env.PRIVATE_KEY3,
        // process.env.PRIVATE_KEY4
      ],
      chainId: 11155111
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_APIKEY
  },
  namedAccounts: {
    firstAccount: {
      default: 0
    },
    secondAccount: {
      default: 1
    },
    thirdAccount: {
      default: 2,
    },
    fourthAccount: {
      default: 3
    }
  },
  gasReporter: {
    enabled: false
  },
};
