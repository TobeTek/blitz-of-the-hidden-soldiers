pragma circom 2.1.0;

include "./_ArrayHasDuplicates.circom";
include "./_PieceRange.circom";

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


template HashCommitmentArray(nPieces) {

    signal input pieceIds[nPieces];
    signal input pieceTypes[nPieces];
    signal input piecePositions[nPieces][2];

    signal output out;

    component pieceHash[nPieces];
    for (var i = 0; i < nPieces; i++){
        pieceHash[i] = HashPieceCommitment();
        pieceHash[i].pieceId <== pieceIds[i];
        pieceHash[i].pieceType <== pieceTypes[i];
        pieceHash[i].piecePosition <== piecePositions[i];
    }
    
    component mimcCommitment = MultiMiMC7(nPieces, 2);
    mimcCommitment.k <== 256;

    for (var i = 0; i < nPieces; i++){
        mimcCommitment.in[i] <== pieceHash[i].out;
    }

    out <== mimcCommitment.out;
}


template SensedSquares(){
    var BOARD_WIDTH = 8;
    var BOARD_HEIGHT = 8;
    var NUMBER_OF_PIECES = 16;
    
    signal input pieceIds[NUMBER_OF_PIECES];
    signal input pieceTypes[NUMBER_OF_PIECES];
    signal input piecePositions[NUMBER_OF_PIECES][2];

    signal output totalPlayerVisibility[BOARD_WIDTH][BOARD_HEIGHT];
    signal output positionCommitment;

    // Assert that there are no duplicates in board positions
    component duplicatePositions = ArrayHasDuplicatePositions(NUMBER_OF_PIECES, 2);
    duplicatePositions.arr <== piecePositions;
    duplicatePositions.out === 0;

    // Determine the squares that are visible to a player
    component pieceVision[NUMBER_OF_PIECES];
    for (var i = 0; i < NUMBER_OF_PIECES; i++){
        pieceVision[i] = PieceRange();
        pieceVision[i].pieceType <== pieceTypes[i];
        pieceVision[i].piecePosition <== piecePositions[i];
    }

    for (var row = 0; row < BOARD_WIDTH; row++){
        for (var col = 0; col < BOARD_HEIGHT; col++){
            var isSeenByAnyPiece = 0;
            for (var i = 0; i < NUMBER_OF_PIECES; i++){
                isSeenByAnyPiece |= pieceVision[i].out[row][col];
            }
            totalPlayerVisibility[row][col] <-- isSeenByAnyPiece;
        }
    }

    // Calculate a hash of the current position
    component hashCommitment = HashCommitmentArray(NUMBER_OF_PIECES);
    hashCommitment.pieceIds <== pieceIds;
    hashCommitment.pieceTypes <== pieceTypes;
    hashCommitment.piecePositions <== piecePositions;

    positionCommitment <== hashCommitment.out;
}

component main = SensedSquares();
