module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    ADMIN = await deployments.get('Admin')


    await deploy('Stakester', {
      from: deployer,
      log: true,
      args:['ipfs://', ADMIN.address]
    });
  };
  module.exports.tags = ['Stakester'];