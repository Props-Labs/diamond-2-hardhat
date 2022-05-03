require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');
require('hardhat-contract-sizer');
require("hardhat-gas-reporter");
require("hardhat-watcher");
require("hardhat-deploy");
require("hardhat-deploy-ethers");
require("@nomiclabs/hardhat-etherscan");

require('dotenv').config();

 module.exports = {
  defaultNetwork: "hardhat",
  gasReporter: {
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    currency: 'USD',
    showTimeSpent: true,
    gasPrice: 60
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: false,
  },
  namedAccounts: {
    deployer: 0,
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
      chainId: 1337
    },
    rinkeby: {
      url: process.env.ALCHEMYAPI_URI_RINKEBY,
      accounts: [process.env.DEPLOYER_RINKEBY_PK],
      gasPrice: 5558817167,
      allowUnlimitedContractSize: false
    },
    mainnet: {
      url: process.env.ALCHEMYAPI_URI_MAINNET,
      accounts: [process.env.DEPLOYER_RINKEBY_PK],
      gasPrice: 70588171670,
      allowUnlimitedContractSize: false
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  solidity: {
    compilers: [
      { version: "0.8.9" }
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 30000
  }
}
