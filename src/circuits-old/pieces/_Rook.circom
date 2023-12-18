pragma circom  2.0.0;

// Determine the squares that are legal for a rook piece
// considering it's initial position as well.
// The result is a 2D array of booleans (0 or 1), indicating if a square
// can be moved to or not.
template Rook(BOARD_WIDTH, BOARD_HEIGHT, ROOK_PIECE_TYPE){
    signal input pieceType;
    signal input piecePosition[2];

    signal output out[BOARD_HEIGHT][BOARD_WIDTH];

    // Initialze board
    var positions[BOARD_HEIGHT][BOARD_WIDTH];
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            // Rook can move any where along the same row
            var isSameRow = (row == piecePosition[0]);
            // Rook can move any where along the same column
            var isSameCol = (col == piecePosition[1]);

            if (isSameRow || isSameCol){
                positions[row][col] = 1;
            }
            else{
                positions[row][col] = 0;
            }
        }
    }
    
    component isRookPiece = IsEqual();
    isRookPiece.in[0] <== ROOK_PIECE_TYPE;
    isRookPiece.in[1] <== pieceType;
    
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- isRookPiece.out * positions[row][col];
        }
    }
}