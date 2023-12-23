import { PieceClass, Piece, PieceSelection } from "@src/types";

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
      x: 0,
      y: 1,
    },
  },
  {
    pieceId: 2,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 1,
      y: 1,
    },
  },
  {
    pieceId: 3,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 2,
      y: 1,
    },
  },
  {
    pieceId: 4,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 3,
      y: 1,
    },
  },
  {
    pieceId: 5,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 4,
      y: 1,
    },
  },
  {
    pieceId: 9,
    pieceClass: PieceClass.ROOK,
    pieceCoords: {
      x: 0,
      y: 0,
    },
  },
  {
    pieceId: 10,
    pieceClass: PieceClass.KNIGHT,
    pieceCoords: {
      x: 1,
      y: 0,
    },
  },
  {
    pieceId: 11,
    pieceClass: PieceClass.BISHOP,
    pieceCoords: {
      x: 2,
      y: 0,
    },
  },
  {
    pieceId: 12,
    pieceClass: PieceClass.QUEEN,
    pieceCoords: {
      x: 3,
      y: 0,
    },
  },
  {
    pieceId: 13,
    pieceClass: PieceClass.KING,
    pieceCoords: {
      x: 4,
      y: 0,
    },
  },
];

export enum KingTokens {
  STANDARD_KING = 1000,
  MAHARAJA_KING = 1002,
  DEVARAJA_KING = 1004,
  MANSA_KING = 1006,
  NEGUS_KING = 1008,

  // Single Edition
  ALEXANDER_THE_GREAT = 1100,
}

export enum QueenTokens {
  STANDARD_QUEEN = 2000,
  PALATINI_QUEEN = 2002,
}

export enum BishopTokens {
  STANDARD_BISHOP = 3000,
  VARANGIAN_GUARD_BISHOP = 3002,
  SAMURAI_BISHOP = 3004,
}

export enum KnightTokens {
  STANDARD_KNIGHT = 4000,
  SAGITTARII_KNIGHT = 4002,
  STRADIOTI_KNIGHT = 4004,
}

export enum RookTokens {
  STANDARD_ROOK = 5000,
  PAVISE_ROOK = 5002,
  JANISSARIES_ROOK = 5004,
}

export enum PawnTokens {
  STANDARD_PAWN = 6000,
  HOPLITES_PAWN = 6002,
  LIMITANEI_PAWN = 6004,
  CONQUISTADORS_PAWN = 6006,
  MAMLUKS_PAWN = 6008,
}

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
