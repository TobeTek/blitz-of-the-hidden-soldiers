import { HardhatEthersSigner as Signer } from "@nomicfoundation/hardhat-ethers";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import {
  Coordinate,
  EthPiece,
  PieceClass,
  calculatePublicCommitment,
} from "@src/types";
import { expect } from "chai";
import { ethers } from "hardhat";
import * as _ from "lodash";
import * as path from "path";
import * as snarkjs from "snarkjs";
// import { smock } from "@defi-wonderland/smock";
import {
  ChessGame,
  PieceMotionPlonkVerifier,
  PlayerVisionPlonkVerifier,
  RevealBoardPositionsPlonkVerifier,
} from "typechain-types";
import { deployCircomVerifiers } from "./common";
import { KingTokens, exoticPieceAllocation, pieceAllocation } from "./fixtures";
import { exoticPlayerPieces, standardPlayerPieces } from "./pieceFixtures";

describe("ChessGame", function () {
  this.timeout(10000000);
  // DEPLOYMENT
  describe("Deployment", function () {
    it("Should set the right player addresses and owner", async function () {
      const { chessGame, playerWhite, playerBlack, gameManager, owner } =
        await loadFixture(deployChessGameFixture);
      expect(await chessGame.playerWhite()).to.equal(playerWhite.address);
      expect(await chessGame.playerBlack()).to.equal(playerBlack.address);
      expect(await chessGame.owner()).to.equal(owner.address);
      expect(await chessGame.gameManagerAddress()).to.equal(
        gameManager.address
      );
    });

    it("Should set player allocations", async function () {
      const { owner, playerWhite, playerBlack, chessGame } = await loadFixture(
        deployChessGameFixture
      );

      expect(
        await chessGame.playerAllocations(playerWhite, KingTokens.STANDARD_KING)
      ).to.deep.equal([PieceClass.KING, KingTokens.STANDARD_KING, 1]);

      // Non-existent allocation
      expect(
        await chessGame.playerAllocations(playerWhite, KingTokens.DEVARAJA_KING)
      ).to.deep.equal([0, 0, 0]);

      expect(
        await chessGame.playerAllocations(
          playerBlack,
          KingTokens.ALEXANDER_THE_GREAT
        )
      ).to.deep.equal([PieceClass.KING, KingTokens.ALEXANDER_THE_GREAT, 1]);

      // Non-existent allocation
      expect(
        await chessGame.playerAllocations(playerBlack, KingTokens.DEVARAJA_KING)
      ).to.deep.equal([0, 0, 0]);
    });

    it("Should have isGameStarted and isGameOver false", async function () {
      const { owner, playerWhite, playerBlack, chessGame } = await loadFixture(
        deployChessGameFixture
      );

      expect(await chessGame.isGameStarted()).to.be.false;
      expect(await chessGame.isGameOver()).to.be.false;
      expect(await chessGame.winner()).to.equal(ethers.ZeroAddress);
    });

    it("Should have playerHasPlacedPieces false", async function () {
      const { owner, playerWhite, playerBlack, chessGame } = await loadFixture(
        deployChessGameFixture
      );
      expect(await chessGame.playerHasPlacedPieces(playerWhite)).to.be.false;
      expect(await chessGame.playerHasPlacedPieces(playerBlack)).to.be.false;
    });
  });

  // PRE-GAME START
  describe("Pre-GameStarted State", function () {
    it("Should allow player white place pieces", async function () {
      const { chessGame, playerWhite } = await loadFixture(
        deployChessGameFixture
      );
      const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
        playerPiecesFixture
      );

      expect(
        await chessGame.connect(playerWhite).placePieces(whitePlayerPieces)
      ).to.be.ok;
    });

    it("Should allow player black place pieces", async function () {
      const { chessGame, playerWhite, playerBlack } = await loadFixture(
        deployChessGameFixture
      );
      const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
        playerPiecesFixture
      );

      expect(
        await chessGame.connect(playerBlack).placePieces(blackPlayerPieces)
      ).to.be.ok;
    });

    it("Shouldn't allow non-players place pieces", async function () {
      const { chessGame, playerWhite, owner, otherAccount } = await loadFixture(
        deployChessGameFixture
      );
      const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
        playerPiecesFixture
      );

      expect(
        async () =>
          await chessGame.connect(otherAccount).placePieces(whitePlayerPieces)
      ).to.be.revertedWith("Only players in this game can call this function");
    });

    it("Shouldn't allow players place pieces different from their allocation", async function () {
      const { chessGame, playerWhite, owner, otherAccount } = await loadFixture(
        deployChessGameFixture
      );
      const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
        playerPiecesFixture
      );

      expect(
        async () =>
          await chessGame.connect(playerWhite).placePieces(blackPlayerPieces)
      ).to.be.revertedWith("Placed pieces do not match player allocation.");
    });

    it("Should fail for pieceId = 0", async function () {
      const { chessGame, playerWhite, playerBlack } = await loadFixture(
        deployChessGameFixture
      );
      const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
        playerPiecesFixture
      );

      // Set Piece ID equal to zero
      let modifiedPlayerPieces = _.cloneDeep(whitePlayerPieces);
      modifiedPlayerPieces[0].pieceId = 0;

      expect(
        async () =>
          await chessGame.connect(playerWhite).placePieces(modifiedPlayerPieces)
      ).to.be.revertedWith("Piece ID can not be equal to zero");
    });
  });

  // GAME ONGOING
  describe("Game Ongoing", function () {
    describe("White player to play turn", function () {
      describe("Should allow playerWhite make move", function () {
        it("makeMove passes", async function () {
          const { chessGame, playerWhite } = await loadFixture(
            deployChessGameWithPlacedPieces
          );
          const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
            playerPiecesFixture
          );

          let d2Pawn = whitePlayerPieces.slice(-1)[0];
          let targetPosition: Coordinate = {
            x: 4,
            y: 2,
          };

          const { proof, publicSignals } = await snarkjs.plonk.fullProve(
            {
              prevPublicCommitment: d2Pawn.publicCommitment,
              pieceId: d2Pawn.pieceId,
              pieceType: d2Pawn.pieceClass,
              pieceInitialPosition: [
                d2Pawn.pieceCoords?.x,
                d2Pawn.pieceCoords?.y,
              ],
              pieceTargetPosition: [targetPosition.x, targetPosition.y],
            },

            path.join(
              "build/compiled_circom/PieceMotion_js",
              "PieceMotion.wasm"
            ),
            path.join("build/zkeys", "PieceMotion.zkey")
          );

          const calldata = await snarkjs.plonk.exportSolidityCallData(
            proof,
            publicSignals
          );

          let [_proof, _pubSignals] = calldata.split("][");
          _proof = JSON.parse(_proof + "]");
          _pubSignals = JSON.parse("[" + _pubSignals);

          expect(
            await chessGame.connect(playerWhite).makeMove(_proof, _pubSignals)
          ).to.be.ok;
        });

        it("reportVision passes", async function () {
          const { chessGame, playerWhite } = await loadFixture(
            deployChessGameWithPlacedPieces
          );
          const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
            playerPiecesFixture
          );

          const { proof, publicSignals } = await snarkjs.plonk.fullProve(
            {
              pieceIds: whitePlayerPieces.map((p) => p.pieceId),
              pieceTypes: whitePlayerPieces.map((p) => p.pieceClass),
              piecePositions: whitePlayerPieces.map((p) => [
                p.pieceCoords?.x,
                p.pieceCoords?.y,
              ]),
            },

            path.join(
              "build/compiled_circom/PlayerVision_js",
              "PlayerVision.wasm"
            ),
            path.join("build/zkeys", "PlayerVision.zkey")
          );
          const calldata = await snarkjs.plonk.exportSolidityCallData(
            proof,
            publicSignals
          );

          let [_proof, _pubSignals] = calldata.split("][");
          _proof = JSON.parse(_proof + "]");
          _pubSignals = JSON.parse("[" + _pubSignals);

          expect(
            async () =>
              await chessGame
                .connect(playerWhite)
                .reportBoardVision(_proof, _pubSignals)
          ).to.be.ok;
        });
      });

      it("Should not allow playerWhite to move non-existent piece ID", async function () {
        const { chessGame, playerWhite } = await loadFixture(
          deployChessGameWithPlacedPieces
        );
        const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
          playerPiecesFixture
        );

        // Dummy proof. Computations can be expensive
        let proof = new Array(24).fill(ethers.ZeroHash);
        // Dummy mimcHash and Non-existent PieceID
        let pubSignals = [ethers.ZeroHash, BigInt(7000)];

        expect(async () => {
          await chessGame.connect(playerWhite).makeMove(proof, pubSignals);
        }).to.be.revertedWith("Player does not have a piece with this ID");
      });

      it("Shouldn't allow playerBlack make move", async function () {
        const { chessGame, playerBlack } = await loadFixture(
          deployChessGameWithPlacedPieces
        );
        const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
          playerPiecesFixture
        );

        // Dummy proof. Computations can be expensive
        let proof = new Array(24).fill(ethers.ZeroHash);
        let pubSignals = new Array(65).fill(ethers.ZeroHash);

        expect(
          async () =>
            await chessGame.connect(playerBlack).makeMove(proof, pubSignals)
        ).to.be.revertedWith("It is not this player's turn to make a move");
      });

      it("Shouldn't allow playerWhite to report vision until white plays", async function () {
        const { chessGame, playerWhite } = await loadFixture(
          deployChessGameWithPlacedPieces
        );

        const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
          playerPiecesFixture
        );
        // Dummy proof. Computations can be expensive
        let proof = new Array(24).fill(ethers.ZeroHash);
        let pubSignals = new Array(65).fill(ethers.ZeroHash);

        expect(
          async () =>
            await chessGame
              .connect(playerWhite)
              .reportBoardVision(proof, pubSignals)
        ).to.be.revertedWith("Attacking player has not played for turn");
      });

      it("Shouldn't allow playerBlack to report vision until white plays", async function () {
        const { chessGame, playerBlack } = await loadFixture(
          deployChessGameWithPlacedPieces
        );

        const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
          playerPiecesFixture
        );
        // Dummy proof. Computations can be expensive
        let proof = new Array(24).fill(ethers.ZeroHash);
        let pubSignals = new Array(65).fill(ethers.ZeroHash);

        expect(
          async () =>
            await chessGame
              .connect(playerBlack)
              .reportBoardVision(proof, pubSignals)
        ).to.be.revertedWith("Attacking player has not played for turn");
      });

      it("Shouldn't allow playerWhite to report positions until white plays", async function () {
        const { chessGame, playerWhite } = await loadFixture(
          deployChessGameWithPlacedPieces
        );

        const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
          playerPiecesFixture
        );
        // Dummy proof. Computations can be expensive
        let proof = new Array(24).fill(ethers.ZeroHash);
        let pubSignals = new Array(64).fill(ethers.ZeroHash);

        expect(
          async () =>
            await chessGame
              .connect(playerWhite)
              .reportPositions(proof, pubSignals)
        ).to.be.revertedWith("Attacking player has not played for turn");
      });

      it("Shouldn't allow playerBlack to report positions until white plays", async function () {
        const { chessGame, playerBlack } = await loadFixture(
          deployChessGameWithPlacedPieces
        );

        const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
          playerPiecesFixture
        );
        // Dummy proof. Computations can be expensive
        let proof = new Array(24).fill(ethers.ZeroHash);
        let pubSignals = new Array(64).fill(ethers.ZeroHash);

        expect(
          async () =>
            await chessGame
              .connect(playerBlack)
              .reportPositions(proof, pubSignals)
        ).to.be.revertedWith("Attacking player has not played for turn");
      });

      it("Shouldn't allow markTurnAsOver to be called", async function () {
        const { chessGame, playerBlack } = await loadFixture(
          deployChessGameWithPlacedPieces
        );
        const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
          playerPiecesFixture
        );
        // Dummy proof. Computations can be expensive
        let proof = new Array(24).fill(ethers.ZeroHash);
        let pubSignals = new Array(64).fill(ethers.ZeroHash);

        expect(
          async () =>
            await chessGame
              .connect(playerBlack)
              .reportPositions(proof, pubSignals)
        ).to.be.revertedWith(
          "A turn can not be marked as completed till both players have reported piece positions"
        );
      });
    });

    describe("Black player to play turn", async function () {
      const {
        chessGame,
        playerBlack,
        playerWhite,
        whitePlayerPieces,
        blackPlayerPieces,
      } = await loadFixture(deployChessGameWithPlacedPieces);

      it("Should allow black to play a move", async function () {
        // Play for white
        let d2Pawn = whitePlayerPieces.slice(-1)[0];
        expect(await playMove(chessGame, playerWhite, d2Pawn, { x: 4, y: 2 }))
          .to.be.ok;

        // Play for black
        let d7Pawn = blackPlayerPieces.slice(-1)[0];
        expect(await playMove(chessGame, playerBlack, d7Pawn, { x: 4, y: 5 }))
          .to.be.ok;
      });
      it("Mark turn as over passes", async function () {
        expect(await chessGame.connect(playerWhite).markTurnAsOver()).to.be.ok;
      });
    });
  });

  // GAME OVER
  describe("Game Over", function () {
    it("Set the right winner and marks pieces as captured", async function () {
      const { chessGame, playerWhite, playerBlack } = await loadFixture(
        deployChessGameWithPlacedPieces
      );
      await playMoves(chessGame, playerWhite, playerBlack);

      expect(await chessGame.winner()).to.be.equal(playerWhite.address);

      const bKingPieceId = 1;
      const bQueenPieceId = 2;
      const bKnightPieceId = 5;

      const wKingPieceId = 1;
      const wQueenPieceId = 2;
      const wKnightPieceId = 5;

      // Check to make sure the right pieces were captured
      expect(await chessGame.capturedPieces(playerBlack, bKingPieceId)).to.be
        .true;
      expect(await chessGame.capturedPieces(playerBlack, bQueenPieceId)).to.be
        .false;
      expect(await chessGame.capturedPieces(playerBlack, bKnightPieceId)).to.be
        .false;

      expect(await chessGame.capturedPieces(playerWhite, wKingPieceId)).to.be
        .false;
      expect(await chessGame.capturedPieces(playerWhite, wQueenPieceId)).to.be
        .false;
      expect(await chessGame.capturedPieces(playerWhite, wKnightPieceId)).to.be
        .false;
    });
  });
});

async function playMoves(
  chessGame: ChessGame,
  playerWhite: Signer,
  playerBlack: Signer
) {
  const { whitePlayerPieces, blackPlayerPieces } = await loadFixture(
    playerPiecesFixture
  );
  // console.log("Simulating/Playing moves for players");
  // console.log("---------------------------------------");
  for (let index = 0; index < whiteCheckmateMoves.length; index++) {
    const whiteMove = whiteCheckmateMoves[index];
    const whitePiece = whitePlayerPieces.filter(
      (v) => v.pieceId === whiteMove.pieceId
    )[0];
    // console.log("[WHITE] Piece: ", whitePiece.pieceId, whiteMove);
    await playMove(chessGame, playerWhite, whitePiece, whiteMove.targetPos);

    whitePiece.pieceCoords = whiteMove.targetPos;
    whitePlayerPieces[index] = whitePiece;
    await submitReportProofs(
      chessGame,
      playerWhite,
      playerBlack,
      whitePlayerPieces,
      blackPlayerPieces
    );
    await chessGame.connect(playerBlack).markTurnAsOver();

    const blackMove = blackCheckmatedMoves[index];
    const blackPiece = blackPlayerPieces.filter(
      (v) => v.pieceId === blackMove.pieceId
    )[0];

    // console.log("[BLACK] Piece: ", blackPiece.pieceId, blackMove);
    await playMove(chessGame, playerBlack, blackPiece, blackMove.targetPos);
    blackPiece.pieceCoords = blackMove.targetPos;
    blackPlayerPieces[index] = blackPiece;
    await submitReportProofs(
      chessGame,
      playerWhite,
      playerBlack,
      whitePlayerPieces,
      blackPlayerPieces
    );
    await chessGame.connect(playerWhite).markTurnAsOver();

    const bKingPieceId = 1;
    const bQueenPieceId = 2;
    const bKnightPieceId = 5;

    const wKingPieceId = 1;
    const wQueenPieceId = 2;
    const wKnightPieceId = 5;

    // Check to make sure the right pieces were captured
    console.log(
      "bKING",
      await chessGame.capturedPieces(playerBlack, bKingPieceId),
      "bQUEEN",
      await chessGame.capturedPieces(playerBlack, bQueenPieceId),
      "bKNIGHT",
      await chessGame.capturedPieces(playerBlack, bKnightPieceId)
    );

    console.log(
      "wKING",
      await chessGame.capturedPieces(playerWhite, wKingPieceId),
      "wQUEEN",
      await chessGame.capturedPieces(playerWhite, wQueenPieceId),
      "wKNIGHT",
      await chessGame.capturedPieces(playerWhite, wKnightPieceId)
    );
  }
}

async function playMove(
  chessGame: ChessGame,
  player: Signer,
  piece: EthPiece,
  targetPos: Coordinate
) {
  let prevPublicCommitment = await calculatePublicCommitment(piece);

  const { proof, publicSignals } = await snarkjs.plonk.fullProve(
    {
      prevPublicCommitment,
      pieceId: piece.pieceId,
      pieceType: piece.pieceClass,
      pieceInitialPosition: [piece.pieceCoords?.x, piece.pieceCoords?.y],
      pieceTargetPosition: [targetPos.x, targetPos.y],
    },

    path.join("build/compiled_circom/PieceMotion_js", "PieceMotion.wasm"),
    path.join("build/zkeys", "PieceMotion.zkey")
  );

  const calldata = await snarkjs.plonk.exportSolidityCallData(
    proof,
    publicSignals
  );

  let [_proof, _pubSignals] = calldata.split("][");
  _proof = JSON.parse(_proof + "]");
  _pubSignals = JSON.parse("[" + _pubSignals);

  await chessGame.connect(player).makeMove(_proof, _pubSignals);
  return chessGame;
}

async function submitReportProofs(
  chessGame: ChessGame,
  playerWhite: Signer,
  playerBlack: Signer,
  whitePlayerPieces: EthPiece[],
  blackPlayerPieces: EthPiece[]
) {
  // Dummy proof. Computations can be expensive
  let proof = new Array(24).fill(ethers.ZeroHash);
  let playerVisionPubSignals = new Array(65).fill(1);

  await chessGame
    .connect(playerWhite)
    .reportBoardVision(proof, playerVisionPubSignals);
  await chessGame
    .connect(playerBlack)
    .reportBoardVision(proof, playerVisionPubSignals);

  let wRevealBoardPositionPubSignals: number[] = [];
  whitePlayerPieces.forEach((p) => {
    wRevealBoardPositionPubSignals.push(p.pieceId);
  });
  whitePlayerPieces.forEach((p) => {
    wRevealBoardPositionPubSignals.push(p.pieceCoords?.x);
    wRevealBoardPositionPubSignals.push(p.pieceCoords?.y);
  });
  whitePlayerPieces.forEach((p) => {
    wRevealBoardPositionPubSignals.push(p.pieceClass);
  });

  let bRevealBoardPositionPubSignals: number[] = [];
  blackPlayerPieces.forEach((p) => {
    bRevealBoardPositionPubSignals.push(p.pieceId);
  });
  blackPlayerPieces.forEach((p) => {
    bRevealBoardPositionPubSignals.push(p.pieceCoords?.x);
    bRevealBoardPositionPubSignals.push(p.pieceCoords?.y);
  });
  blackPlayerPieces.forEach((p) => {
    bRevealBoardPositionPubSignals.push(p.pieceClass);
  });

  await chessGame
    .connect(playerWhite)
    .reportPositions(proof, wRevealBoardPositionPubSignals);
  await chessGame
    .connect(playerBlack)
    .reportPositions(proof, bRevealBoardPositionPubSignals);
}

async function playerPiecesFixture() {
  const whitePlayerPieces: EthPiece[] = _.cloneDeep(standardPlayerPieces);
  for (const piece of whitePlayerPieces) {
    piece.publicCommitment = await calculatePublicCommitment(piece);
  }

  const blackPlayerPieces = _.cloneDeep(exoticPlayerPieces);
  for (const piece of blackPlayerPieces) {
    piece.publicCommitment = await calculatePublicCommitment(piece);
  }

  return { whitePlayerPieces, blackPlayerPieces };
}

async function deployChessGameFixture() {
  // const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  // const ONE_GWEI = 1_000_000_000;

  // const lockedAmount = ONE_GWEI;
  // const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

  const {
    pieceMotionPlonkVerifier,
    playerVisionPlonkVerifier,
    revealBoardPositionsPlonkVerifier,
  } = await loadFixture(deployCircomVerifiers);
  const [owner, playerWhite, playerBlack, gameManager, otherAccount] =
    await ethers.getSigners();

  const ChessGame = await ethers.getContractFactory("ChessGame");
  const chessGame = await ChessGame.deploy(
    owner.address,
    gameManager.address,
    playerWhite.address,
    playerBlack.address
  );

  await chessGame.changeRevealBoardPositionVerifier(
    await revealBoardPositionsPlonkVerifier.getAddress()
  );
  await chessGame.changePieceMotionVerifier(
    await pieceMotionPlonkVerifier.getAddress()
  );
  await chessGame.changePlayerVisionVerifier(
    await playerVisionPlonkVerifier.getAddress()
  );

  await chessGame.setPlayerAllocation(playerWhite, pieceAllocation);
  await chessGame.setPlayerAllocation(playerBlack, exoticPieceAllocation);

  return {
    chessGame,
    playerWhite,
    playerBlack,
    gameManager,
    owner,
    otherAccount,
  };
}

async function deployChessGameWithPlacedPieces() {
  const whitePlayerPieces: EthPiece[] = _.cloneDeep(standardPlayerPieces);
  for (const piece of whitePlayerPieces) {
    piece.publicCommitment = await calculatePublicCommitment(piece);
  }

  const blackPlayerPieces = _.cloneDeep(exoticPlayerPieces);
  for (const piece of blackPlayerPieces) {
    piece.publicCommitment = await calculatePublicCommitment(piece);
  }

  const {
    pieceMotionPlonkVerifier,
    playerVisionPlonkVerifier,
    revealBoardPositionsPlonkVerifier,
  } = await loadFixture(deployCircomVerifiers);
  const [owner, playerWhite, playerBlack, gameManager, otherAccount] =
    await ethers.getSigners();

  const ChessGame = await ethers.getContractFactory("ChessGame");
  const chessGame = await ChessGame.deploy(
    owner.address,
    gameManager.address,
    playerWhite.address,
    playerBlack.address
  );

  await chessGame.changeRevealBoardPositionVerifier(
    await revealBoardPositionsPlonkVerifier.getAddress()
  );
  await chessGame.changePieceMotionVerifier(
    await pieceMotionPlonkVerifier.getAddress()
  );
  await chessGame.changePlayerVisionVerifier(
    await playerVisionPlonkVerifier.getAddress()
  );

  await chessGame.setPlayerAllocation(playerWhite, pieceAllocation);
  await chessGame.setPlayerAllocation(playerBlack, exoticPieceAllocation);

  await chessGame.connect(playerWhite).placePieces(whitePlayerPieces);
  await chessGame.connect(playerBlack).placePieces(blackPlayerPieces);

  return {
    chessGame,
    playerWhite,
    playerBlack,
    gameManager,
    owner,
    otherAccount,
    whitePlayerPieces: _.cloneDeep(whitePlayerPieces),
    blackPlayerPieces: _.cloneDeep(blackPlayerPieces),
    pieceMotionPlonkVerifier,
    playerVisionPlonkVerifier,
    revealBoardPositionsPlonkVerifier,
  };
}

const whiteCheckmateMoves = [
  {
    pieceId: 10,
    targetPos: {
      x: 4,
      y: 2,
    },
  },
  {
    pieceId: 2,
    targetPos: {
      x: 6,
      y: 3,
    },
  },
  {
    pieceId: 2,
    targetPos: {
      x: 6,
      y: 7,
    },
  },
  // Checkmate!
  {
    pieceId: 2,
    targetPos: {
      x: 4,
      y: 7,
    },
  },
];
const blackCheckmatedMoves = [
  {
    pieceId: 6,
    targetPos: {
      x: 0,
      y: 5,
    },
  },
  {
    pieceId: 6,
    targetPos: {
      x: 0,
      y: 4,
    },
  },
  {
    pieceId: 7,
    targetPos: {
      x: 1,
      y: 5,
    },
  },
  {
    pieceId: 7,
    targetPos: {
      x: 1,
      y: 4,
    },
  },
];
