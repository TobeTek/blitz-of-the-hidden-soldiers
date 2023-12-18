pragma circom  2.0.0;


include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/mimc.circom";

include "_common.circom";
include "_PieceRange.circom";
include "./pieces/_Bishop.circom";
include "./pieces/_King.circom";
include "./pieces/_Knight.circom";
include "./pieces/_Pawn.circom";
include "./pieces/_Queen.circom";
include "./pieces/_Rook.circom";


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