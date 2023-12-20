import { EthPiece, PieceClass } from "@src/types";
import {
  KnightTokens,
  BishopTokens,
  KingTokens,
  QueenTokens,
  RookTokens,
  PawnTokens,
} from "./fixtures";

export const standardPlayerPieces: EthPiece[] = [
  // KING
  {
    pieceId: 1,
    tokenId: KingTokens.STANDARD_KING,
    pieceClass: PieceClass.KING,
    pieceCoords: {
      x: 4,
      y: 0,
    },
    isDead: false,
  },
  // QUEEN
  {
    pieceId: 2,
    tokenId: QueenTokens.STANDARD_QUEEN,
    pieceClass: PieceClass.QUEEN,
    pieceCoords: {
      x: 3,
      y: 0,
    },
    isDead: false,
  },
  // ROOKS
  {
    pieceId: 3,
    tokenId: RookTokens.STANDARD_ROOK,
    pieceClass: PieceClass.ROOK,
    pieceCoords: {
      x: 0,
      y: 0,
    },
    isDead: false,
  },
  {
    pieceId: 4,
    tokenId: RookTokens.STANDARD_ROOK,
    pieceClass: PieceClass.ROOK,
    pieceCoords: {
      x: 7,
      y: 0,
    },
    isDead: false,
  },
  // BISHOPS
  {
    pieceId: 5,
    tokenId: BishopTokens.STANDARD_BISHOP,
    pieceClass: PieceClass.BISHOP,
    pieceCoords: {
      x: 1,
      y: 0,
    },
    isDead: false,
  },
  {
    pieceId: 6,
    tokenId: BishopTokens.STANDARD_BISHOP,
    pieceClass: PieceClass.BISHOP,
    pieceCoords: {
      x: 6,
      y: 0,
    },
    isDead: false,
  },
  // KNIGHTS
  {
    pieceId: 7,
    tokenId: KnightTokens.STANDARD_KNIGHT,
    pieceClass: PieceClass.KNIGHT,
    pieceCoords: {
      x: 2,
      y: 0,
    },
    isDead: false,
  },
  {
    pieceId: 8,
    tokenId: KnightTokens.STANDARD_KNIGHT,
    pieceClass: PieceClass.KNIGHT,
    pieceCoords: {
      x: 5,
      y: 0,
    },
    isDead: false,
  },
  // PAWNS
  {
    pieceId: 9,
    tokenId: PawnTokens.STANDARD_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 0,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 10,
    tokenId: PawnTokens.STANDARD_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 1,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 11,
    tokenId: PawnTokens.STANDARD_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 2,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 12,
    tokenId: PawnTokens.STANDARD_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 3,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 13,
    tokenId: PawnTokens.STANDARD_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 4,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 14,
    tokenId: PawnTokens.STANDARD_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 5,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 15,
    tokenId: PawnTokens.STANDARD_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 6,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 16,
    tokenId: PawnTokens.STANDARD_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 7,
      y: 1,
    },
    isDead: false,
  },
];

export const exoticPlayerPieces: EthPiece[] = [
  // KING
  {
    pieceId: 1,
    tokenId: KingTokens.ALEXANDER_THE_GREAT,
    pieceClass: PieceClass.KING,
    pieceCoords: {
      x: 4,
      y: 0,
    },
    isDead: false,
  },
  // QUEEN
  {
    pieceId: 2,
    tokenId: QueenTokens.PALATINI_QUEEN,
    pieceClass: PieceClass.QUEEN,
    pieceCoords: {
      x: 3,
      y: 0,
    },
    isDead: false,
  },
  // ROOKS
  {
    pieceId: 3,
    tokenId: RookTokens.PAVISE_ROOK,
    pieceClass: PieceClass.ROOK,
    pieceCoords: {
      x: 0,
      y: 0,
    },
    isDead: false,
  },
  {
    pieceId: 4,
    tokenId: RookTokens.PAVISE_ROOK,
    pieceClass: PieceClass.ROOK,
    pieceCoords: {
      x: 7,
      y: 0,
    },
    isDead: false,
  },
  // BISHOPS
  {
    pieceId: 5,
    tokenId: BishopTokens.VARANGIAN_GUARD_BISHOP,
    pieceClass: PieceClass.BISHOP,
    pieceCoords: {
      x: 1,
      y: 0,
    },
    isDead: false,
  },
  {
    pieceId: 6,
    tokenId: BishopTokens.VARANGIAN_GUARD_BISHOP,
    pieceClass: PieceClass.BISHOP,
    pieceCoords: {
      x: 6,
      y: 0,
    },
    isDead: false,
  },
  // KNIGHTS
  {
    pieceId: 7,
    tokenId: KnightTokens.SAGITTARII_KNIGHT,
    pieceClass: PieceClass.KNIGHT,
    pieceCoords: {
      x: 2,
      y: 0,
    },
    isDead: false,
  },
  {
    pieceId: 8,
    tokenId: KnightTokens.SAGITTARII_KNIGHT,
    pieceClass: PieceClass.KNIGHT,
    pieceCoords: {
      x: 5,
      y: 0,
    },
    isDead: false,
  },
  // PAWNS
  {
    pieceId: 9,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 0,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 10,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 1,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 11,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 2,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 12,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 3,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 13,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 4,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 14,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 5,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 15,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 6,
      y: 1,
    },
    isDead: false,
  },
  {
    pieceId: 16,
    tokenId: PawnTokens.CONQUISTADORS_PAWN,
    pieceClass: PieceClass.PAWN,
    pieceCoords: {
      x: 7,
      y: 1,
    },
    isDead: false,
  },
];
