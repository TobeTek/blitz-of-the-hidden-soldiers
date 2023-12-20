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

describe("ChessGame", function () {
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

    // Contracts are deployed using the first signer/account by default
    const [owner, playerWhite, playerBlack, gameManager, otherAccount] =
      await ethers.getSigners();

    const ChessGame = await ethers.getContractFactory("ChessGame");
    const chessGame = await ChessGame.deploy(
      owner.address,
      gameManager.address,
      playerWhite.address,
      playerBlack.address
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

  describe.skip("Game Ongoing", function () {
    describe("Validations", function () {
      it("Should revert with the right error if called too soon", async function () {
        const { lock } = await loadFixture(deployOneYearLockFixture);

        await expect(lock.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async function () {
        const { lock, unlockTime, otherAccount } = await loadFixture(
          deployOneYearLockFixture
        );

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime);

        // We use lock.connect() to send a transaction from another account
        await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
          "You aren't the owner"
        );
      });

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { lock, unlockTime } = await loadFixture(
          deployOneYearLockFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).not.to.be.reverted;
      });
    });

    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { lock, unlockTime, lockedAmount } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw())
          .to.emit(lock, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).to.changeEtherBalances(
          [owner, lock],
          [lockedAmount, -lockedAmount]
        );
      });
    });
  });

  describe.skip("Game Over", function () {
    describe("Validations", function () {
      it("Should revert with the right error if called too soon", async function () {
        const { lock } = await loadFixture(deployOneYearLockFixture);

        await expect(lock.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async function () {
        const { lock, unlockTime, otherAccount } = await loadFixture(
          deployOneYearLockFixture
        );

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime);

        // We use lock.connect() to send a transaction from another account
        await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
          "You aren't the owner"
        );
      });

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { lock, unlockTime } = await loadFixture(
          deployOneYearLockFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).not.to.be.reverted;
      });
    });

    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { lock, unlockTime, lockedAmount } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw())
          .to.emit(lock, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).to.changeEtherBalances(
          [owner, lock],
          [lockedAmount, -lockedAmount]
        );
      });
    });
  });
});
