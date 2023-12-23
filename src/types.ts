import { mimcHashMulti } from "@src/utils/hashers";
export const UNDEFINED_COORD = 1e10;
export const NUMBER_OF_PIECES = 10;
export const BOARD_WIDTH = 8;
export const BOARD_HEIGHT = 8;

export type Coordinate = {
  x: number;
  y: number;
};

export type Piece = {
  pieceId: number;
  pieceClass: PieceClass;
  pieceCoords?: Coordinate;
};

export type EthPiece = Piece & {
  tokenId: number;
  publicCommitment?: number | string;
  isDead: boolean;
};

export async function calculatePublicCommitment(p: EthPiece): Promise<string> {
  return await mimcHashMulti([
    p.pieceId,
    p.pieceClass,
    p.pieceCoords?.x,
    p.pieceCoords?.y,
  ]);
}

export enum PieceClass {
  // Standard Pieces
  KING,
  QUEEN,
  BISHOP,
  KNIGHT,
  ROOK,
  PAWN,

  // Exotic
  TREBUCHET,
}

export type PieceSelection = {
  pieceClass: PieceClass;
  tokenId: number;
  count: number;
};
