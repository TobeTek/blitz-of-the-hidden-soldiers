import { mimcHashMulti } from "@src/utils/hashers";
import { Coordinate, Piece, PieceClass } from "@src/types";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const c_tester = require("circom_tester").c;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
const p = Scalar.fromString(
  "21888242871839275222246405745257275088548364400416034343698204186575808495617"
);
const Fr = new F1Field(p);
const expect = chai.expect;

describe("PieceMotion.circom", function () {
  this.timeout(100000);
  const piece: Piece = {
    pieceId: 1,
    pieceClass: PieceClass.PAWN,
  };

  async function compileCircuitFixture() {
    const circuit = await wasm_tester(
      path.join("src/circuits", "PieceMotion.circom"),
      { verbose: false }
    );
    return { circuit };
  }

  it("Passes for valid pawn move", async function () {
    const piece: Piece = {
      pieceId: 1,
      pieceClass: PieceClass.PAWN,
    };
    const initialPos: Coordinate = {
      x: 0,
      y: 0,
    };
    const targetPos: Coordinate = {
      x: 0,
      y: 1,
    };

    let prevPublicCommitment = await mimcHashMulti([
      piece.pieceId,
      piece.pieceClass,
      initialPos.x,
      initialPos.y,
    ]);

    const { circuit } = await loadFixture(compileCircuitFixture);
    const w = await circuit.calculateWitness({
      prevPublicCommitment,
      pieceId: piece.pieceId,
      pieceType: piece.pieceClass,
      pieceInitialPosition: [initialPos.x, initialPos.y],
      pieceTargetPosition: [targetPos.x, targetPos.y],
    });
    await circuit.checkConstraints(w);
  });

  it("Fails for invalid prevCommitment", async function () {
    const initialPos: Coordinate = {
      x: 0,
      y: 0,
    };
    const targetPos: Coordinate = {
      x: 0,
      y: 1,
    };

    // Invalid commitment
    let prevPublicCommitment = await mimcHashMulti([
      100,
      PieceClass.BISHOP,
      initialPos.x,
      initialPos.y,
    ]);

    const { circuit } = await loadFixture(compileCircuitFixture);
    try {
      const w = await circuit.calculateWitness({
        prevPublicCommitment,
        pieceId: piece.pieceId,
        pieceType: piece.pieceClass,
        pieceInitialPosition: [initialPos.x, initialPos.y],
        pieceTargetPosition: [targetPos.x, targetPos.y],
      });

      await circuit.checkConstraints(w);
    } catch (err: any) {
      expect(err.message)
        .to.contain("Assert Failed")
        .to.contain("Error in template PieceMotion");
    }
  });

  it("Fails for invalid pawn move", async function () {
    const initialPos: Coordinate = {
      x: 0,
      y: 0,
    };
    const targetPos: Coordinate = {
      x: 4,
      y: 4,
    };

    let prevPublicCommitment = await mimcHashMulti([
      piece.pieceId,
      piece.pieceClass,
      initialPos.x,
      initialPos.y,
    ]);

    const { circuit } = await loadFixture(compileCircuitFixture);
    try {
      const w = await circuit.calculateWitness({
        prevPublicCommitment,
        pieceId: piece.pieceId,
        pieceType: piece.pieceClass,
        pieceInitialPosition: [initialPos.x, initialPos.y],
        pieceTargetPosition: [targetPos.x, targetPos.y],
      });
      await circuit.checkConstraints(w);
    } catch (err: any) {
      expect(err.message)
        .to.contain("Assert Failed")
        .to.contain("Error in template PieceMotion");
    }
  });
});
