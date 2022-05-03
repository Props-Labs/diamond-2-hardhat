const { expect } = require("chai");
const { ethers, network } = require("hardhat");
const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
// ethers
let owner = {};
let sender = {};
let receiver = {};

module.exports = async ({getNamedAccounts, deployments, ethers}) => {
  console.log("DEPLOYING...")
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();

};

module.exports.tags = ['Project'];
module.exports.skip = async () => network.name !== 'hardhat';
