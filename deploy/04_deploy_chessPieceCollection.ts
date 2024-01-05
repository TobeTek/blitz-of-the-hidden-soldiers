// TypeScript
import { DeployFunction, DeployResult } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { network, ethers } from "hardhat";
import {
  ChessPieceCollection,
  ChessPieceCollection__factory,
} from "typechain-types";
import {
  KnightTokens,
  BishopTokens,
  KingTokens,
  QueenTokens,
  RookTokens,
  PawnTokens,
} from "src/types/tokens";

import { ChessPieceProperties, PieceClass } from "@src/types";

const collectionTokens = {
  tokenIds: [
    KingTokens.STANDARD_KING,
    KingTokens.ALEXANDER_THE_GREAT,
    QueenTokens.STANDARD_QUEEN,
    KnightTokens.STANDARD_KNIGHT,
    BishopTokens.STANDARD_BISHOP,
    RookTokens.STANDARD_ROOK,
    PawnTokens.STANDARD_PAWN,
  ],
  amounts: [1, 1, 1, 1, 1, 1, 1],
  properties: [
    [KingTokens.STANDARD_KING, PieceClass.KING],
    [KingTokens.ALEXANDER_THE_GREAT, PieceClass.KING],
    [QueenTokens.STANDARD_QUEEN, PieceClass.QUEEN],
    [KnightTokens.STANDARD_KNIGHT, PieceClass.KNIGHT],
    [BishopTokens.STANDARD_BISHOP, PieceClass.BISHOP],
    [RookTokens.STANDARD_ROOK, PieceClass.ROOK],
    [PawnTokens.STANDARD_PAWN, PieceClass.PAWN],
  ],
};

const deployChessPieceCollection: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();
  const chainId = network.config.chainId!;
  const owner = await ethers.getSigner(deployer);

  const deployResult: DeployResult = await deploy("ChessPieceCollection", {
    from: deployer,
    log: true,
    args: [deployer],
    waitConfirmations: chainId == 31337 ? 1 : 6,
  });

  const chessCollection = await ethers.getContractAt(
    deployResult.abi,
    deployResult.address,
    owner
  );
  await chessCollection.mintBatchWithProperties(
    owner.address,
    collectionTokens.tokenIds,
    collectionTokens.amounts,
    ethers.encodeBytes32String("0x0"),
    collectionTokens.properties
  );
};

export default deployChessPieceCollection;
deployChessPieceCollection.tags = ["all", "game", "chessCollection", "mainnet"];
