pragma circom  2.1.0;


// Determine the squares that are legal for a king piece
// considering it's initial position as well.
// The result is a 2D array of booleans (0 or 1), indicating if a square
// can be moved to or not.
template King(BOARD_WIDTH, BOARD_HEIGHT, KING_PIECE_TYPE){
    signal input pieceType;
    signal input piecePosition[2];

    signal output out[BOARD_HEIGHT][BOARD_WIDTH];

    var noMoves = 8;
    var moveTransforms[noMoves][2];
    
    // Vertical
    moveTransforms[0] = [0, 1];
    moveTransforms[1] = [0, -1];

    // Horizontal
    moveTransforms[2] = [1, 0];
    moveTransforms[3] = [-1, 0];

    // Diagonal
    moveTransforms[4] = [1, 1];
    moveTransforms[5] = [1, -1];
    moveTransforms[6] = [-1, 1];
    moveTransforms[7] = [-1, -1];

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

    component isKingPiece = IsEqual();
    isKingPiece.in[0] <== KING_PIECE_TYPE;
    isKingPiece.in[1] <== pieceType;
    
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- isKingPiece.out * positions[row][col];
        }
    }
}