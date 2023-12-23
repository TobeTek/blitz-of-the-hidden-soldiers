// TypeScript
import { DeployFunction, DeployResult } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { network } from "hardhat";

const deployRevealBoardPositionsPlonkVerifier: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();
  const chainId = network.config.chainId!;

  const revealBoardPositionsPlonkVerifier: DeployResult = await deploy(
    "RevealBoardPositionsPlonkVerifier",
    {
      from: deployer,
      log: true,
      args: [],
      waitConfirmations: chainId == 31337 ? 1 : 6,
    }
  );
};

export default deployRevealBoardPositionsPlonkVerifier;
deployRevealBoardPositionsPlonkVerifier.tags = ["all", "circom_verifiers"];
