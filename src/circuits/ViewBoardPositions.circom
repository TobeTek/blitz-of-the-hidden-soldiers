pragma circom 2.0.0;

template ViewBoardPosition(MAX_PIECES_PER_PLAYER){
    // CONSTANTS
    var UNDEFINED_COORDINATE = -1;
    var MAX_BOARD_POSITION[2] = [8, 8];
    var MIN_BOARD_POSITION[2] = [0, 0];
    var NUMBER_OF_BOARD_SQUARES = (
        (MAX_BOARD_POSITION[0] * MAX_BOARD_POSITION[1])
        - (MIN_BOARD_POSITION[0] * MIN_BOARD_POSITION[1])
    );

    signal input requestedPositions[NUMBER_OF_BOARD_SQUARES][2];
    signal input piecePositions[MAX_PIECES_PER_PLAYER][2];
    signal input hashSecret;
    

    // Pieces that are kept hidden return the UNDEFINED coordinate value
    signal output visiblePieceType[MAX_PIECES_PER_PLAYER];
    signal output visiblePieceId[MAX_PIECES_PER_PLAYER];
    signal output visiblePiecePosition[MAX_PIECES_PER_PLAYER][2];

    // Piece: type, id, position
}

component main = ViewBoardPosition(16);
