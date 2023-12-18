pragma circom  2.1.0;

include "circomlib/comparators.circom";

template RevealBoardPositions() {
    var BOARD_WIDTH = 8;
    var BOARD_HEIGHT = 8;
    var NUMBER_OF_PIECES = 8;
    
    signal input opponentVision[BOARD_WIDTH][BOARD_HEIGHT];
    signal input pieceIds[NUMBER_OF_PIECES];
    signal input pieceTypes[NUMBER_OF_PIECES];
    signal input piecePositions[NUMBER_OF_PIECES][2];
    
    signal output visiblePieceIds[NUMBER_OF_PIECES];
    signal output visiblePieceTypes[NUMBER_OF_PIECES];
    signal output visiblePiecePositions[NUMBER_OF_PIECES][2];

    component piecePositionEq[NUMBER_OF_PIECES];
    
    for (var i = 0; i < NUMBER_OF_PIECES; i++){
        var row = piecePositions[i][0];
        var col = piecePositions[i][0];
        
        piecePositionEq[i] = IsEqual();
        
        // Is board square visible to opponent?
        piecePositionEq[i].in[0] <-- opponentVision[row][col];
        piecePositionEq[i].in[1] <-- 1;

        
        visiblePieceIds[i] <== piecePositionEq[i].out * pieceIds[i];
        visiblePieceTypes[i] <== piecePositionEq[i].out * pieceTypes[i];
        visiblePiecePositions[i][0] <== piecePositionEq[i].out * piecePositions[i][0];
        visiblePiecePositions[i][1] <== piecePositionEq[i].out * piecePositions[i][1];
    }
    
}

component main = RevealBoardPositions();

/*
INPUT = {
    "opponentVision": [
        [0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 1, 0],
        [0, 1, 0, 1, 0, 1, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 0, 1, 1, 1, 0, 0, 0],
        [0, 1, 0, 1, 0, 1, 0, 0],
        [1, 0, 0, 1, 0, 0, 1, 0]
    ],
    "pieceIds": ["0x559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd", "0xdf7e70e5021544f4834bbee64a9e3789febc4be81470df629cad6ddb03320a5c", "0x6b23c0d5f35d1b11f9b683f0b0a617355deb11277d91ae091d399c655b87940d", "0x3f39d5c348e5b79d06e842c114e6cc571583bbf44e4b0ebfda1a01ec05745d43", "0xa9f51566bd6705f7ea6ad54bb9deb449f795582d6529a0e22207b8981233ec58", "0xf67ab10ad4e4c53121b6a5fe4da9c10ddee905b978d3788d2723d7bfacbe28a9", "0x333e0a1e27815d0ceee55c473fe3dc93d56c63e3bee2b3b4aee8eed6d70191a3", "0x44bd7ae60f478fae1061e11a7739f4b94d1daf917982d33b6fc8a01a63f89c21"],
    "pieceTypes": ["0", "1", "1", "2", "2", "3", "4", "5"],
    "piecePositions":[
        ["0", "0"],
        ["2", "1"],
        ["3", "6"],
        ["2", "2"],
        ["1", "1"],
        ["1", "5"],
        ["7", "1"],
        ["0", "1"]
    ]
}
*/