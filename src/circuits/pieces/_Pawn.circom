pragma circom  2.0.0;

include "./_common.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";

// Determine the squares that are legal for a pawn piece
// considering it's initial position as well.
// The result is a 2D array of booleans (0 or 1), indicating if a square
// can be moved to or not.
template Pawn(BOARD_WIDTH, BOARD_HEIGHT, PAWN_PIECE_TYPE){
    signal input pieceType;
    signal input piecePosition[2];

    signal output out[BOARD_HEIGHT][BOARD_WIDTH];

    // Initialze board
    var positions[BOARD_HEIGHT][BOARD_WIDTH];
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            positions[row][col] = 0;
            
        }
    }
    
    // Pawns can move forward 
    component frontSquare = ClampedBoardPosition();
    frontSquare.position <== [piecePosition[0], piecePosition[1] + 1];
    positions[frontSquare.out[0]][frontSquare.out[1]] = 1;

    component isPawnPiece = IsEqual();
    isPawnPiece.in[0] <== PAWN_PIECE_TYPE;
    isPawnPiece.in[1] <== pieceType;
    
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- isPawnPiece.out * positions[row][col];
        }
    }
}