pragma circom 2.1.5;

include "../../node_modules/circomlib/circuits/mimcsponge.circom";
include "./_PieceRange.circom";

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
    
    component mimcCommitment = MiMCSponge(nPieces, 220, 1);
    mimcCommitment.k <== 0;

    for (var i = 0; i < nPieces; i++){
        mimcCommitment.ins[i] <== pieceHash[i].out;
    }

    out <== mimcCommitment.outs[0];
}


// Check if there are any duplicate elements in an array
// If the array is multidimensional, it considers each sub-array as a unique element
template ArrayHasDuplicatePositions(arraySize, nDims) {
    signal input arr[arraySize][nDims];
    signal output out;

    var numEqComp = (arraySize + 1);
    component isEqComp[numEqComp][nDims];

    // Loop through pairs of array elements to check for equality in each dimension
    for (var i = 0; i <= arraySize; i++){
        var elem1 = i % arraySize;
        var elem2 = (i  + 1 ) % arraySize;
        for (var dim = 0; dim < nDims; dim++){
            isEqComp[i][dim] = IsEqual();
            isEqComp[i][dim].in[0] <== arr[elem1][dim];
            isEqComp[i][dim].in[1] <== arr[elem2][dim];
        }
    }

    // Check if elements are equal in each dimension and store the result
    var isEqualPosition[numEqComp];
    for(var i = 0; i < numEqComp; i++){
        var isElemEq = 1;
        for (var dim = 0; dim < nDims; dim++){
            isElemEq &= isEqComp[i][dim].out;
        }
        isEqualPosition[i] = isElemEq;
    }

    var anyEq = 0;
    for (var i = 0; i < numEqComp; i++){
        anyEq |= isEqualPosition[i];
    }

    out <-- anyEq;
}

// Determine which squares a player can see, given their current pieces
// TODO: Ignore pieces that are dead. They can't contribute to player vision
template PlayerVision(){
    var BOARD_WIDTH = 8;
    var BOARD_HEIGHT = 8;
    var NUMBER_OF_PIECES = 16;
    
    signal input pieceIds[NUMBER_OF_PIECES];
    signal input pieceTypes[NUMBER_OF_PIECES];
    signal input piecePositions[NUMBER_OF_PIECES][2];

    signal output totalPlayerVisibility[BOARD_WIDTH][BOARD_HEIGHT];
    signal output positionCommitment;

    // // Assert that there are no duplicates in board positions
    // component duplicatePositions = ArrayHasDuplicatePositions(NUMBER_OF_PIECES, 2);
    // duplicatePositions.arr <== piecePositions;
    // duplicatePositions.out === 0;

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

component main = PlayerVision();
