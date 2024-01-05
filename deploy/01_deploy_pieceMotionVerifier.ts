// TypeScript
import { DeployFunction, DeployResult } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { network } from "hardhat";

const deployPieceMotionPlonkVerifier: DeployFunction = async (
    hre: HardhatRuntimeEnvironment
) => {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();
    const chainId = network.config.chainId!;

    const pieceMotionPlonkVerifier: DeployResult = await deploy("PieceMotionPlonkVerifier", {
        from: deployer,
        log: true,
        args: [],
        waitConfirmations: chainId == 31337 ? 1 : 6,
    });
};

export default deployPieceMotionPlonkVerifier;
deployPieceMotionPlonkVerifier.tags = ["all", "circom_verifiers", "mainnet"];