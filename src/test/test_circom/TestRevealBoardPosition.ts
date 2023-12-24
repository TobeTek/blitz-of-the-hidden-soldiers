import { standardPieceLayout, playerVision } from "@src/test/fixtures";
import { exoticPlayerPieces, standardPlayerPieces } from "../pieceFixtures";
import { PieceClass, NUMBER_OF_PIECES } from "@src/types";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
const p = Scalar.fromString(
  "21888242871839275222246405745257275088548364400416034343698204186575808495617"
);
const Fr = new F1Field(p);
const expect = chai.expect;

describe("RevealBoardPositions.circom", function () {
  this.timeout(100000);
  const pieceIds: number[] = standardPieceLayout.map((p) => p.pieceId);
  const pieceTypes: PieceClass[] = standardPieceLayout.map((p) => p.pieceClass);
  const piecePositions: number[][] = standardPieceLayout.map((p) => [
    p.pieceCoords?.x,
    p.pieceCoords?.y,
  ]) as number[][];
  let visiblePieceIds: number[] = [];
  standardPieceLayout.forEach((piece) => {
    if (playerVision[piece.pieceCoords?.x][piece.pieceCoords?.y]) {
      visiblePieceIds.push(piece.pieceId);
    }
  });

  async function compileCircuitFixture() {
    const circuit = await wasm_tester(
      path.join("src/circuits", "RevealBoardPositions.circom"),
      { verbose: false }
    );
    return { circuit };
  }

  it("Passes for valid input", async function () {
    const { circuit } = await loadFixture(compileCircuitFixture);
    const w = await circuit.calculateWitness({
      opponentVision: playerVision,
      pieceIds,
      pieceTypes,
      piecePositions,
    });

    let wVisiblePieceIds = w.slice(0, NUMBER_OF_PIECES),
      wVisiblePiecePositions = w.slice(NUMBER_OF_PIECES, NUMBER_OF_PIECES * 2),
      wVisiblePieceTypes = w.slice(NUMBER_OF_PIECES * 2);

    for (const pieceId of visiblePieceIds) {
      expect(wVisiblePieceIds.includes(Fr.e(pieceId))).to.be.true;
    }

    await circuit.checkConstraints(w);
  });

  it("Fails for duplicate [input] piece positions", async function () {
    let duplicatePositions = piecePositions.slice();
    duplicatePositions[1] = duplicatePositions[0];

    try {
      const { circuit } = await loadFixture(compileCircuitFixture);
      const w = await circuit.calculateWitness({
        opponentVision: playerVision,
        pieceIds,
        pieceTypes,
        piecePositions: duplicatePositions,
      });

      await circuit.checkConstraints(w);
    } catch (err: any) {
      expect(err.message)
        .to.contain("Assert Failed")
        .to.contain("Error in template RevealBoardPosition");
    }
  });
});
