import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { standardPieceLayout } from "@src/test/fixtures";
import { PieceClass } from "@src/types";
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

describe("PlayerVision.circom", function () {
  this.timeout(100000);
  const pieceIds: number[] = standardPieceLayout.map((p) => p.pieceId);
  const pieceTypes: PieceClass[] = standardPieceLayout.map((p) => p.pieceClass);
  const piecePositions: number[][] = standardPieceLayout.map((p) => [
    p.pieceCoords?.x,
    p.pieceCoords?.y,
  ]) as number[][];

  async function compileCircuitFixture() {
    const circuit = await wasm_tester(
      path.join("src/circuits", "PlayerVision.circom"),
      { verbose: false }
    );
    return { circuit };
  }

  it("Passes for valid input", async function () {
    const { circuit } = await loadFixture(compileCircuitFixture);
    const w = await circuit.calculateWitness({
      pieceIds,
      pieceTypes,
      piecePositions,
    });
    await circuit.checkConstraints(w);
  });

  it("Fails for duplicate [input] piece positions", async function () {
    let duplicatePositions = [...piecePositions];
    duplicatePositions[1] = duplicatePositions[0];

    const { circuit } = await loadFixture(compileCircuitFixture);
    try {
      const w = await circuit.calculateWitness({
        pieceIds,
        pieceTypes,
        piecePositions: duplicatePositions,
      });

      await circuit.checkConstraints(w);
    } catch (err: any) {
      expect(err.message)
        .to.contain("Assert Failed")
        .to.contain("Error in template PlayerVision");
    }
  });
});
