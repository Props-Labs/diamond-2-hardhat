const { getSelectors, FacetCutAction } = require('./../scripts/libraries/diamond.js')

const FacetNames = [
    'DiamondLoupeFacet',
    'OwnershipFacet'
  ]

const cut = []

module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    //deploy each facet, add to cut[]
    for (const FacetName of FacetNames) {
        console.log(`Deploying ${FacetName}`)
        let facet = await deploy(FacetName, {
            from: deployer,
            log: true,
          });

         facet = await ethers.getContractAt(FacetName, facet.address);

        console.log(`${FacetName} deployed: ${facet.address}`)
        cut.push({
          facetAddress: facet.address,
          action: FacetCutAction.Add,
          functionSelectors: getSelectors(facet)
        })
      }

      DIAMOND = await deployments.get('Diamond')
      DIAMONDINIT = await deployments.get('DiamondInit')

      diamondInit = await ethers.getContractAt('DiamondInit', DIAMONDINIT.address);

      const diamondCut = await ethers.getContractAt('IDiamondCut', DIAMOND.address)

      let tx
        let receipt
    // call to init function
    let functionCall = diamondInit.interface.encodeFunctionData('init')
    tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
    console.log('Diamond cut tx: ', tx.hash)
    receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    console.log('Completed diamond cut')

  };
  module.exports.tags = ['DeployFacets'];