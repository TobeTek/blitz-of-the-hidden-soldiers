pragma circom  2.0.0;


include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/mimc.circom";

include "_common.circom";
include "./pieces/_Bishop.circom";
include "./pieces/_King.circom";
include "./pieces/_Knight.circom";
include "./pieces/_Pawn.circom";
include "./pieces/_Queen.circom";
include "./pieces/_Rook.circom";

template PieceRange() {
    var BOARD_WIDTH = 8;
    var BOARD_HEIGHT = 8;

    // Piece types
    var KING_PIECE_TYPE = 0;
    var QUEEN_PIECE_TYPE = 10;
    var BISHOP_PIECE_TYPE = 20;
    var KNIGHT_PIECE_TYPE = 30;
    var PAWN_PIECE_TYPE = 40;
    var ROOK_PIECE_TYPE = 50;

    signal input pieceType;
    signal input piecePosition[2];
    signal output out[BOARD_WIDTH][BOARD_HEIGHT];

    // All piece types
    component bishopMoves = Bishop(BOARD_WIDTH, BOARD_HEIGHT, BISHOP_PIECE_TYPE);
    bishopMoves.piecePosition[0] <== piecePosition[0];
    bishopMoves.piecePosition[1] <== piecePosition[1];
    bishopMoves.pieceType <== pieceType;

    component kingMoves = King(BOARD_WIDTH, BOARD_HEIGHT, KING_PIECE_TYPE);
    kingMoves.piecePosition[0] <== piecePosition[0];
    kingMoves.piecePosition[1] <== piecePosition[1];
    kingMoves.pieceType <== pieceType;

    component knightMoves = Knight(BOARD_WIDTH, BOARD_HEIGHT, KNIGHT_PIECE_TYPE);
    knightMoves.piecePosition[0] <== piecePosition[0];
    knightMoves.piecePosition[1] <== piecePosition[1];
    knightMoves.pieceType <== pieceType;

    component pawnMoves = Pawn(BOARD_WIDTH, BOARD_HEIGHT, PAWN_PIECE_TYPE);
    pawnMoves.piecePosition[0] <== piecePosition[0];
    pawnMoves.piecePosition[1] <== piecePosition[1];
    pawnMoves.pieceType <== pieceType;

    component queenMoves = Queen(BOARD_WIDTH, BOARD_HEIGHT, QUEEN_PIECE_TYPE);
    queenMoves.piecePosition[0] <== 3;
    queenMoves.piecePosition[1] <== 4;
    queenMoves.pieceType <== pieceType;

    component rookMoves = Rook(BOARD_WIDTH, BOARD_HEIGHT, ROOK_PIECE_TYPE);
    rookMoves.piecePosition[0] <== piecePosition[0];
    rookMoves.piecePosition[1] <== piecePosition[1];
    rookMoves.pieceType <== pieceType;

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

template HashPieceCommitment(){
    signal input pieceId;
    signal input pieceType;
    signal input piecePosition[2];

    signal output out;

    component mimcCommitment = MultiMiMC7(4, 2);
    mimcCommitment.k <== 256;

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

    var LEGAL_SQUARE = 1;

    signal input prevPublicCommitment; // public
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
    component isEq = IsEqual();
    isEq.in[0] <-- pieceRange.out[targetRow][targetCol];
    isEq.in[1] <-- LEGAL_SQUARE;
    1 === isEq.out;
    
    // Calculate new commitment
    component pieceCommitment = HashPieceCommitment();
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