pragma circom  2.0.0;

// Determine the squares that are legal for a rook piece
// considering it's initial position as well.
// The result is a 2D array of booleans (0 or 1), indicating if a square
// can be moved to or not.
template Bishop(BOARD_WIDTH, BOARD_HEIGHT, BISHOP_PIECE_TYPE){
    signal input pieceType;
    signal input piecePosition[2];

    signal output out[BOARD_HEIGHT][BOARD_WIDTH];

    // Initialze board
    var positions[BOARD_HEIGHT][BOARD_WIDTH];
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            // Calculate if a square is diagonal to initial position
            var isDiagonal = (piecePosition[0] - row) == (piecePosition[1] - col);
            var isDiagonal2 = (piecePosition[0] - row) == -(piecePosition[1] - col);

            if (isDiagonal || isDiagonal2){
                positions[row][col] = 1;
            }
            else{
                positions[row][col] = 0;
            }
        }
    }
    
    component isBishopPiece = IsEqual();
    isBishopPiece.in[0] <== BISHOP_PIECE_TYPE;
    isBishopPiece.in[1] <== pieceType;
    
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- isBishopPiece.out * positions[row][col];
        }
    }
}