pragma circom  2.1.5;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/mimcsponge.circom";

include "./pieces/_Bishop.circom";
include "./pieces/_King.circom";
include "./pieces/_Knight.circom";
include "./pieces/_Pawn.circom";
include "./pieces/_Queen.circom";
include "./pieces/_Rook.circom";

// Determine the legal moves for a piece given it's type and position
template PieceRange() {
    var BOARD_WIDTH = 8;
    var BOARD_HEIGHT = 8;

    // Piece types
    var KING_PIECE_TYPE = 0;
    var QUEEN_PIECE_TYPE = 1;
    var BISHOP_PIECE_TYPE = 2;
    var KNIGHT_PIECE_TYPE = 3;
    var ROOK_PIECE_TYPE = 4;
    var PAWN_PIECE_TYPE = 5;

    signal input pieceType;
    signal input piecePosition[2];
    signal output out[BOARD_WIDTH][BOARD_HEIGHT];

    // All piece types
    component kingMoves = King(BOARD_WIDTH, BOARD_HEIGHT, KING_PIECE_TYPE);
    kingMoves.piecePosition[0] <== piecePosition[0];
    kingMoves.piecePosition[1] <== piecePosition[1];
    kingMoves.pieceType <== pieceType;

    component queenMoves = Queen(BOARD_WIDTH, BOARD_HEIGHT, QUEEN_PIECE_TYPE);
    queenMoves.piecePosition[0] <== piecePosition[0];
    queenMoves.piecePosition[1] <== piecePosition[1];
    queenMoves.pieceType <== pieceType;

    component bishopMoves = Bishop(BOARD_WIDTH, BOARD_HEIGHT, BISHOP_PIECE_TYPE);
    bishopMoves.piecePosition[0] <== piecePosition[0];
    bishopMoves.piecePosition[1] <== piecePosition[1];
    bishopMoves.pieceType <== pieceType;

    component knightMoves = Knight(BOARD_WIDTH, BOARD_HEIGHT, KNIGHT_PIECE_TYPE);
    knightMoves.piecePosition[0] <== piecePosition[0];
    knightMoves.piecePosition[1] <== piecePosition[1];
    knightMoves.pieceType <== pieceType;

    component rookMoves = Rook(BOARD_WIDTH, BOARD_HEIGHT, ROOK_PIECE_TYPE);
    rookMoves.piecePosition[0] <== piecePosition[0];
    rookMoves.piecePosition[1] <== piecePosition[1];
    rookMoves.pieceType <== pieceType;

    component pawnMoves = Pawn(BOARD_WIDTH, BOARD_HEIGHT, PAWN_PIECE_TYPE);
    pawnMoves.piecePosition[0] <== piecePosition[0];
    pawnMoves.piecePosition[1] <== piecePosition[1];
    pawnMoves.pieceType <== pieceType;

    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- (
                bishopMoves.out[row][col]
                || kingMoves.out[row][col]
                || knightMoves.out[row][col]
                || pawnMoves.out[row][col]
                || queenMoves.out[row][col]
                || rookMoves.out[row][col]
            );
        }
    }
}