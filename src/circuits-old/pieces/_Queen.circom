pragma circom  2.0.0;

include "../_common.circom";

// Determine the squares that are legal for a queen piece
// considering it's initial position as well.
// The result is a 2D array of booleans (0 or 1), indicating if a square
// can be moved to or not.
template Queen(BOARD_WIDTH, BOARD_HEIGHT, QUEEN_PIECE_TYPE){
    signal input pieceType;
    signal input piecePosition[2];

    signal output out[BOARD_HEIGHT][BOARD_WIDTH];

    // Initialze board
    var positions[BOARD_HEIGHT][BOARD_WIDTH];
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            // Queen's can move any where along the same row
            var isSameRow = (row == piecePosition[0]);
            // Queen's can move any where along the same column
            var isSameCol = (col == piecePosition[1]);
            // Calculate if a square is diagonal to initial position
            var isDiagonal = (piecePosition[0] - row) == (piecePosition[1] - col);
            var isDiagonal2 = (piecePosition[0] - row) == -(piecePosition[1] - col);
            
            if (isDiagonal || isDiagonal2 || isSameRow || isSameCol){
                positions[row][col] = 1;
            }
            else{
                positions[row][col] = 0;
            }
        }
    }
    
    component isQueenPiece = IsEqual();
    isQueenPiece.in[0] <== QUEEN_PIECE_TYPE;
    isQueenPiece.in[1] <== pieceType;
    
    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- isQueenPiece.out * positions[row][col];
        }
    }
}