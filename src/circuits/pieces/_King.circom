pragma circom  2.0.0;

// Determine the squares that are legal for a king piece
// considering it's initial position as well.
// The result is a 2D array of booleans (0 or 1), indicating if a square
// can be moved to or not.
template King(BOARD_WIDTH, BOARD_HEIGHT, KING_PIECE_TYPE){
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
    
    // King can move forward
    component frontSquare = ClampedBoardPosition();
    frontSquare.position <== [piecePosition[0], piecePosition[1] + 1];
    positions[frontSquare.out[0]][frontSquare.out[1]] = 1;

    // King can move backwards
    component backSquare = ClampedBoardPosition();
    backSquare.position <== [piecePosition[0], piecePosition[1] - 1];
    positions[backSquare.out[0]][backSquare.out[1]] = 1;

    // King can move left
    component leftSquare = ClampedBoardPosition();
    leftSquare.position <== [piecePosition[0] - 1, piecePosition[1]];
    positions[leftSquare.out[0]][leftSquare.out[1]] = 1;

    // King can move right
    component rightSquare = ClampedBoardPosition();
    rightSquare.position <== [piecePosition[0] + 1, piecePosition[1]];
    positions[rightSquare.out[0]][rightSquare.out[1]] = 1;

    component isKingPiece = IsEqual();
    isKingPiece.in[0] <== KING_PIECE_TYPE;
    isKingPiece.in[1] <== pieceType;
    
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- isKingPiece.out * positions[row][col];
        }
    }
}