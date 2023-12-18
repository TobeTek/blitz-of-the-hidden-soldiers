pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/mux1.circom";
include "../../node_modules/circomlib/circuits/mimc.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/gates.circom";


template Max() {
    signal input a;
    signal input b;
    signal output out;

    var BITSIZE = 64;
    
    component aIsGt = GreaterThan(BITSIZE);
    aIsGt.in[0] <== a;
    aIsGt.in[1] <== b;

    component bIsGt = NOT();
    bIsGt.in <== aIsGt.out;

    signal aGt <== (aIsGt.out * a);
    signal bGt <== (bIsGt.out * b);
    out <==  aGt + bGt;
}

template Min() {
    signal input a;
    signal input b;
    signal output out;

    var BITSIZE = 64;
 
    component aIsGt = LessThan(BITSIZE);
    aIsGt.in[0] <== a;
    aIsGt.in[1] <== b;

    component bIsGt = NOT();
    bIsGt.in <== aIsGt.out;

    signal aGt <== (aIsGt.out * a);
    signal bGt <== (bIsGt.out * b);
    out <==  aGt + bGt;
}

template IsLegalBoardPosition(){
    // CONSTANTS
    var MAX_BOARD_INDEX[2] = [7, 7];
    var MIN_BOARD_INDEX[2] = [0, 0];

    var BITSIZE = 64;

    signal input position[2];
    signal output out;
    
    // Position can not exceed (be larger than) max board size
    component maxBoardPositions[2];

    maxBoardPositions[0] = LessThan(BITSIZE);
    maxBoardPositions[0].a <== position[0] + 1;
    maxBoardPositions[0].b <== MAX_BOARD_INDEX[0];
    
    maxBoardPositions[1] = LessThan(BITSIZE);
    maxBoardPositions[1].a <== position[1] + 1;
    maxBoardPositions[1].b <== MAX_BOARD_INDEX[1];

    // Position can not exceed (be smaller than) min board size
    component minBoardPositions[2];
    minBoardPositions[0] = GreaterThan(BITSIZE);
    minBoardPositions[0].a <== position[0] + 1;
    minBoardPositions[0].b <== MIN_BOARD_INDEX[0];

    minBoardPositions[1] = GreaterThan(BITSIZE);
    minBoardPositions[1].a <== position[1] + 1;
    minBoardPositions[1].b <== MIN_BOARD_INDEX[1];

    out[0] <-- (
        minBoardPositions[0].out
        || minBoardPositions[1].out
        || maxBoardPositions[0].out
        || maxBoardPositions[1].out
    );
}

template ClampedBoardPosition(){
    // CONSTANTS
    var MAX_BOARD_INDEX[2] = [7, 7];
    var MIN_BOARD_INDEX[2] = [0, 0];

    signal input position[2];
    signal output out[2];
    
    // Position can not exceed (be larger than) max board size
    component maxBoardPositions[2];

    maxBoardPositions[0] = Min();
    maxBoardPositions[0].a <== position[0] + 1;
    maxBoardPositions[0].b <== MAX_BOARD_INDEX[0];
    
    maxBoardPositions[1] = Min();
    maxBoardPositions[1].a <== position[1] + 1;
    maxBoardPositions[1].b <== MAX_BOARD_INDEX[1];

    log("Max Board Pos");
    log(maxBoardPositions[0].out, maxBoardPositions[1].out);

    // Position can not exceed (be smaller than) min board size
    component minBoardPositions[2];
    minBoardPositions[0] = Max();
    minBoardPositions[0].a <-- maxBoardPositions[0].out;
    minBoardPositions[0].b <-- MIN_BOARD_INDEX[0];

    minBoardPositions[1] = Max();
    minBoardPositions[1].a <-- maxBoardPositions[1].out;
    minBoardPositions[1].b <-- MIN_BOARD_INDEX[1];

    out[0] <== minBoardPositions[0].out;
    out[1] <== minBoardPositions[1].out;
}

template IsBoardPositionEqual(){
    signal input position1[2];
    signal input position2[2];
    signal output out;

    component positionIsEqual[2];
    positionIsEqual[0] = IsEqual();
    positionIsEqual[1] = IsEqual();

    positionIsEqual[0].in[0] <== position1[0];
    positionIsEqual[0].in[1] <== position2[0];

    positionIsEqual[1].in[0] <== position1[1];
    positionIsEqual[1].in[1] <== position2[1];

    // Undefined coordinates can never be equal
    // A single undefined coordinate means there can
    // not be equality
    component positionIsUndefined[2];
    positionIsUndefined[0] = IsEqual();
    positionIsUndefined[1] = IsEqual();

    positionIsUndefined[0].in[0] <== position1[0];
    positionIsUndefined[0].in[1] <== -1;

    positionIsUndefined[1].in[0] <== position1[1];
    positionIsUndefined[1].in[1] <== -1;

    component notIsUndefinedPosition = NOT();
    notIsUndefinedPosition.in <== (
        positionIsUndefined[0].out
        * positionIsUndefined[1].out
    );
    
    signal equalPosition <== positionIsEqual[0].out * positionIsEqual[1].out;
    out <== equalPosition * notIsUndefinedPosition.out;
}

// circuit to ensure there aren't two pieces of the same player in the same position
template CheckDuplicatePiecePositions(MAX_PIECES_PER_PLAYER, UNDEFINED_COORDINATE){
    signal input piecePositions[MAX_PIECES_PER_PLAYER][2];
    signal output out;

    component positionEqual[MAX_PIECES_PER_PLAYER][MAX_PIECES_PER_PLAYER][2];

    for(var i = 0; i < MAX_PIECES_PER_PLAYER; i++){
        for(var j = 0; j < MAX_PIECES_PER_PLAYER; j++){
            // Row
            positionEqual[i][j][0] = IsEqual();
            positionEqual[i][j][0].in[0] <== piecePositions[i][0];
            positionEqual[i][j][0].in[1] <== piecePositions[j][0];

            // Column
            positionEqual[i][j][1] = IsEqual();
            positionEqual[i][j][1].in[0] <== piecePositions[i][1];
            positionEqual[i][j][1].in[1] <== piecePositions[j][1];
        } 
    }

    signal duplicatePositions[MAX_PIECES_PER_PLAYER * MAX_PIECES_PER_PLAYER + 1];
    duplicatePositions[0] <== 1;
    var duplicatePositionsIndx = 1;
    
    for(var i = 0; i < MAX_PIECES_PER_PLAYER; i++){
        for(var j = 0; j < MAX_PIECES_PER_PLAYER; j++){
            if(i != j){
                duplicatePositions[duplicatePositionsIndx] <== (
                    duplicatePositions[duplicatePositionsIndx - 1] * positionEqual[i][j].out
                );
            }
            else {
                // The same piece should be ignored when checking for duplicates
                duplicatePositions[duplicatePositionsIndx] <== 0;
            }
            duplicatePositionsIndx++;
        } 
    }

    out <== duplicatePositions[MAX_PIECES_PER_PLAYER * MAX_PIECES_PER_PLAYER - 1];   
}

template HashBoardPositionArray(nPieces){
    signal input in[nPieces][2];
    signal output out;

    component mimcHash = MultiMiMC7(nPieces * 2, 2);
    mimcHash.k <== 256;
  
    for (var i = 0; i < nPieces; i++){
        var pos[2] = in[i];
        var hashIndx = i * 2;
        mimcHash.in[hashIndx] <==  pos[0];
        mimcHash.in[hashIndx + 1] <== pos[1];
  }

  out <== mimcHash.out;
}
