import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import {
  pieceAllocation,
  exoticPieceAllocation,
  KingTokens,
  QueenTokens,
} from "./fixtures";
import { PieceClass, EthPiece, calculatePublicCommitment } from "@src/types";
import { standardPlayerPieces, exoticPlayerPieces } from "./pieceFixtures";
import * as _ from "lodash";

export async function deployCircomVerifiers() {
  const [owner, playerWhite, playerBlack, gameManager, otherAccount] =
    await ethers.getSigners();

  // PieceMotion
  const PieceMotionPlonkVerifier = await ethers.getContractFactory(
    "MockPieceMotion"
  );
  const pieceMotionPlonkVerifier = await PieceMotionPlonkVerifier.deploy();

  // PlayerVision
  const PlayerVisionPlonkVerifier = await ethers.getContractFactory(
    "MockPlayerVision"
  );
  const playerVisionPlonkVerifier = await PlayerVisionPlonkVerifier.deploy();

  // RevealBoardPositions
  const RevealBoardPositionsPlonkVerifier = await ethers.getContractFactory(
    "MockRevealBoardPositions"
  );
  const revealBoardPositionsPlonkVerifier =
    await RevealBoardPositionsPlonkVerifier.deploy();

  return {
    playerVisionPlonkVerifier,
    pieceMotionPlonkVerifier,
    revealBoardPositionsPlonkVerifier,
    PlayerVisionPlonkVerifier,
    PieceMotionPlonkVerifier,
    RevealBoardPositionsPlonkVerifier
  };
}
