import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployVotingZKPContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;
  const verifier = await hre.deployments.get("Groth16Verifier");

  await deploy("VotingZKP", {
    from: deployer,
    // Contract constructor arguments
    args: [verifier.address],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const votingZKP = await hre.ethers.getContract<Contract>("VotingZKP", deployer);
  console.log("VotingZKP deployed at:", votingZKP.address);
};

export default deployVotingZKPContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployVotingZKPContract.tags = ["VotingZKP"];
