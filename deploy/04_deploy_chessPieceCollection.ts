// TypeScript
import { DeployFunction, DeployResult } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { network, ethers } from "hardhat";
import { ChessPieceCollection, ChessPieceCollection__factory } from "typechain-types";

const deployChessPieceCollection: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();
  const chainId = network.config.chainId!;

  const deployResult: DeployResult = await deploy(
    "ChessPieceCollection",
    {
      from: deployer,
      log: true,
      args: [deployer],
      waitConfirmations: chainId == 31337 ? 1 : 6,
    }
  );

};

export default deployChessPieceCollection;
deployChessPieceCollection.tags = ["all", "game", "chessCollection"];
