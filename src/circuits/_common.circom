pragma circom 2.0.0;

template Max() {
    signal input a;
    signal input b;
    signal output out;

    var BITSIZE = 64;
 
    // Use some bitwise magic to extract the sign bit
    var z = (a - b);
    var i = ( z >> BITSIZE-1) & 1;
 
    // Find the maximum number
    out <== a - (i * z);
}

template Min() {
    signal input a;
    signal input b;
    signal output out;

    var BITSIZE = 64;
 
    // Use some bitwise magic to extract the sign bit
    var z = (a - b);
    var i = ( z >> BITSIZE-1) & -1;
 
    // Find the minimum number
    out <== a - (i * z);
}

template ClampedBoardPosition(){
    signal input position;
    signal output out[2];

    var MAX_BOARD_POSITION[2] = [8, 8];
    var MIN_BOARD_POSITION[2] = [0, 0];
    
    // Position can not exceed max board size
    component maxBoardPositions[2] = [Max(), Max()];
    maxBoardPositions[0].a = position[0] + 1;
    maxBoardPositions[0].b = MAX_BOARD_POSITION[0];
    
    maxBoardPositions[1].a = position[1] + 1;
    maxBoardPositions[1].b = MAX_BOARD_POSITION[1];

    // Position can not exceed min board size
    component minBoardPositions[2] = [Min(), Min()];
    minBoardPositions[0].a = maxBoardPositions[0].out;
    minBoardPositions[0].b = maxBoardPositions[1].out;
    
    minBoardPositions[1].a = position[1] + 1;
    minBoardPositions[1].b = MIN_BOARD_POSITION[1];

    out[0] <== minBoardPositions[0].out;
    out[1] <== minBoardPositions[1].out;
}

template IsBoardPositionEqual(){
    signal input position1[2];
    signal input position2[2];
    signal output out;

    component positionIsEqual = [IsEqual(), IsEqual()];
    positionIsEqual[0].in[0] = position1[0];
    positionIsEqual[0].in[1] = position2[0];

    positionIsEqual[1].in[0] = position1[1];
    positionIsEqual[1].in[1] = position2[1];

    // Undefined coordinates can never be equal
    // A single undefined coordinate means there can
    // not be equality
    component positionIsUndefined[2] = [IsEqual(), IsEqual()];
    positionIsUndefined.in[0] <== position1[0];
    positionIsUndefined.in[1] <== -1;

    positionIsUndefined.in[0] <== position1[1];
    positionIsUndefined.in[1] <== -1;

    component notIsUndefinedPosition = NOT();
    notIsUndefinedPosition.in <== positionIsUndefined[0].out & positionIsUndefined[1].out;

    out <== positionIsEqual[0].out & positionIsEqual[1].out & notIsUndefinedPosition.out;
}

// making sure there aren't two pieces of the same player in the same position
template CheckDuplicatePiecePositions(){
    var MAX_PIECES_PER_PLAYER = 16;
    var UNDEFINED_COORDINATE = -1;
    signal input piecePositions[MAX_PIECES_PER_PLAYER][2];
    signal output out;

    for(var i = 0; i < MAX_PIECES_PER_PLAYER; i++){
        for(var j = 0; j < MAX_PIECES_PER_PLAYER; j++){
            if(i != j){
                log("Hello");
            }
        } 
    }
}