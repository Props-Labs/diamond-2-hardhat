module.exports = async ({getNamedAccounts, deployments, run}) => {
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();
    let contract = await deploy('Admin', {
      from: deployer,
      log: true,
    });
  };
  module.exports.tags = ['Admin'];
