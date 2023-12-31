// TypeScript
import { DeployFunction, DeployResult } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { network, ethers } from "hardhat";
import { ChessPieceCollection, ChessPieceCollection__factory } from "typechain-types";
import { chessPieceCollectionSol } from "typechain-types/src/contracts";

const deployGameManager: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();
  const chainId = network.config.chainId!;

  const [owner] = await ethers.getSigners();
  const chessCollectionAddress = await ethers.getContract("ChessPieceCollection", deployer);

  const deployResult: DeployResult = await deploy(
    "GameManager",
    {
      from: deployer,
      log: true,
      args: [deployer, await chessCollectionAddress.getAddress()],
      waitConfirmations: chainId == 31337 ? 1 : 6,
    }
  );

};

export default deployGameManager;
deployGameManager.tags = ["all", "game", "gameManager"];
