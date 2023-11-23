pragma circom  2.1.0;


// Determine the squares that are legal for a knight piece
// considering it's initial position as well.
// The result is a 2D array of booleans (0 or 1), indicating if a square
// can be moved to or not.
template Knight(BOARD_WIDTH, BOARD_HEIGHT, KNIGHT_PIECE_TYPE){
    signal input pieceType;
    signal input piecePosition[2];

    signal output out[BOARD_HEIGHT][BOARD_WIDTH];

    var noMoves = 8;
    var moveTransforms[noMoves][2];
    
    moveTransforms[0] = [2, 1];
    moveTransforms[1] = [2, -1];
    moveTransforms[2] = [-2, 1];
    moveTransforms[3] = [-2, -1];
    moveTransforms[4] = [1, 2];
    moveTransforms[5] = [1, -2];
    moveTransforms[6] = [-1, 2];
    moveTransforms[7] = [-1, -2];
    
    var moves[noMoves][2];

    // Initialze board
    var positions[BOARD_HEIGHT][BOARD_WIDTH];
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            positions[row][col] = 0;
        }
    }

    // Apply the transformations to the board position
    for (var i = 0; i < noMoves; i++){
        moves[i][0] = piecePosition[0] + moveTransforms[i][0];
        moves[i][1] = piecePosition[1] + moveTransforms[i][1];
    }

    for (var i = 0; i < noMoves; i++){
        var row = moves[i][0];
        var col = moves[i][1];
        positions[row][col] = 1;
    }

    component isKnightPiece = IsEqual();
    isKnightPiece.in[0] <== KNIGHT_PIECE_TYPE;
    isKnightPiece.in[1] <== pieceType;
    
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- isKnightPiece.out * positions[row][col];
        }
    }
}