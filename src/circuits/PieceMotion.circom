pragma circom  2.0.0;

include "./_common.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
// include "https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom";

template PieceRange() {
    var BOARD_WIDTH = 8;
    var BOARD_HEIGHT = 8;

    // Piece types
    var KING_PIECE_TYPE = 0;
    var QUEEN_PIECE_TYPE = 1;
    var PAWN_PIECE_TYPE = 2;

    signal input pieceType;
    signal input piecePosition[2];
    signal output out[BOARD_WIDTH][BOARD_HEIGHT];

    // All piece types
    component pawnMoves = Pawn(BOARD_WIDTH, BOARD_HEIGHT, PAWN_PIECE_TYPE);
    pawnMoves.piecePosition[0] <== piecePosition[0];
    pawnMoves.piecePosition[1] <== piecePosition[1];
    pawnMoves.pieceType <== pieceType;

    component queenMoves = Queen(BOARD_WIDTH, BOARD_HEIGHT, QUEEN_PIECE_TYPE);
    queenMoves.piecePosition[0] <== 3;
    queenMoves.piecePosition[1] <== 4;
    queenMoves.pieceType <== pieceType;

    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_WIDTH; col++){
            out[row][col] <-- pawnMoves.out[row][col] || queenMoves.out[row][col];
        }
    }
}

template HashPieceCommitment(){
    signal input pieceId;
    signal input pieceType;
    signal input piecePosition[2];

    signal output out;

    component mimcCommitment = MultiMiMC7(4);
    mimcCommitment.in[0] <== pieceId;
    mimcCommitment.in[1] <== pieceType;
    mimcCommitment.in[2] <== piecePosition[0];
    mimcCommitment.in[3] <== piecePosition[1];

    out <== mimcCommitment.out;
}

// A circuit that proves a piece can move from one square to the next.
// It also calculates a commitment of that new position.
// It is the commitment that gets stored on-chain
template PieceMotion() {
    var BOARD_WIDTH = 8;
    var BOARD_HEIGHT = 8;

    signal public input prevPublicCommitment;
    signal input pieceId;
    signal input pieceType;
    signal input pieceInitialPosition[2];
    signal input pieceTargetPosition[2];
    signal output publicCommitment;

    // Create initial public commitment, and ensure it matches signal
    component initialPieceCommitment = HashPieceCommitment();
    initialPieceCommitment.pieceId <== pieceId;
    initialPieceCommitment.pieceType <== pieceType;
    initialPieceCommitment.piecePosition <== pieceInitialPosition;

    initialPieceCommitment.out === prevPublicCommitment;

    component pieceRange = PieceRange();
    pieceRange.pieceType <== pieceType;
    pieceRange.piecePosition <== pieceInitialPosition;

    // Must be a valid move
    var targetRow = pieceTargetPosition[0];
    var targetCol = pieceTargetPosition[1];
    pieceRange.out[targetRow][targetCol] === 1;
    
    // Calculate new commitment
    component pieceCommitment = pieceCommitment();
    pieceCommitment.pieceId <== pieceId;
    pieceCommitment.pieceType <== pieceType;
    pieceCommitment.piecePosition <== pieceInitialPosition;

    publicCommitment <== pieceCommitment.out;
}


component main = PieceMotion();

/* INPUT = {
    "pieceType": "2",
    "piecePosition": ["3", "4"]
} */