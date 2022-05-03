module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    let DiamondCutFacet = await deployments.get('DiamondCutFacet')

    await deploy('Diamond', {
      from: deployer,
      log: true,
      args: [deployer, DiamondCutFacet.address],
    });
  };
  module.exports.tags = ['Diamond'];