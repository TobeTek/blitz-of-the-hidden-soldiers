import { PieceClass, Piece, PieceSelection } from "@src/types";
import { KingTokens, KnightTokens, QueenTokens, RookTokens, PawnTokens, BishopTokens } from "src/types/tokens";

export const playerVision = [
  [0, 1, 0, 0, 1, 0, 0, 1],
  [1, 0, 0, 1, 0, 0, 1, 0],
  [0, 0, 0, 0, 0, 1, 0, 0],
  [0, 0, 0, 0, 1, 0, 0, 1],
  [0, 0, 0, 1, 0, 0, 1, 0],
  [0, 0, 1, 0, 0, 1, 0, 0],
  [0, 1, 0, 0, 1, 0, 0, 0],
  [1, 0, 0, 1, 0, 0, 0, 0],
];

export const standardPieceLayout: Piece[] = [
  {
    pieceId: 1,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 1,
      y: 2,
    },
  },
  {
    pieceId: 2,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 2,
      y: 2,
    },
  },
  {
    pieceId: 3,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 3,
      y: 2,
    },
  },
  {
    pieceId: 4,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 4,
      y: 2,
    },
  },
  {
    pieceId: 5,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 5,
      y: 2,
    },
  },
  {
    pieceId: 6,
    pieceClass: PieceClass.ROOK,
    pieceCoords: {
      x: 6,
      y: 2,
    },
  },
  {
    pieceId: 7,
    pieceClass: PieceClass.KNIGHT,
    pieceCoords: {
      x: 1,
      y: 1,
    },
  },
  {
    pieceId: 8,
    pieceClass: PieceClass.BISHOP,
    pieceCoords: {
      x: 2,
      y: 1,
    },
  },
  {
    pieceId: 9,
    pieceClass: PieceClass.QUEEN,
    pieceCoords: {
      x: 3,
      y: 1,
    },
  },
  {
    pieceId: 10,
    pieceClass: PieceClass.KING,
    pieceCoords: {
      x: 4,
      y: 1,
    },
  },
];

export const pieceAllocation: PieceSelection[] = [
  {
    pieceClass: PieceClass.KING,
    tokenId: KingTokens.STANDARD_KING,
    count: 1,
  },
  {
    pieceClass: PieceClass.QUEEN,
    tokenId: QueenTokens.STANDARD_QUEEN,
    count: 1,
  },
  {
    pieceClass: PieceClass.BISHOP,
    tokenId: BishopTokens.STANDARD_BISHOP,
    count: 1,
  },
  {
    pieceClass: PieceClass.KNIGHT,
    tokenId: KnightTokens.STANDARD_KNIGHT,
    count: 1,
  },
  {
    pieceClass: PieceClass.ROOK,
    tokenId: RookTokens.STANDARD_ROOK,
    count: 1,
  },
  {
    pieceClass: PieceClass.PAWN,
    tokenId: PawnTokens.STANDARD_PAWN,
    count: 5,
  },
];

export const exoticPieceAllocation: PieceSelection[] = [
  {
    pieceClass: PieceClass.KING,
    tokenId: KingTokens.ALEXANDER_THE_GREAT,
    count: 1,
  },
  {
    pieceClass: PieceClass.QUEEN,
    tokenId: QueenTokens.PALATINI_QUEEN,
    count: 1,
  },
  {
    pieceClass: PieceClass.BISHOP,
    tokenId: BishopTokens.VARANGIAN_GUARD_BISHOP,
    count: 1,
  },
  {
    pieceClass: PieceClass.KNIGHT,
    tokenId: KnightTokens.SAGITTARII_KNIGHT,
    count: 1,
  },
  {
    pieceClass: PieceClass.ROOK,
    tokenId: RookTokens.PAVISE_ROOK,
    count: 1,
  },
  {
    pieceClass: PieceClass.PAWN,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    count: 5,
  },
];
