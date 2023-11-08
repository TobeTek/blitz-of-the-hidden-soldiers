pragma circom 2.0.0;

include "../_common.circom";
include "../../../node_modules/circomlib/circuits/mux1.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../../../node_modules/circomlib/circuits/gates.circom";

// calculate positions a chess can move from an origin position
// without considering other pieces on the board
template getPieceRange(BOARD_SIZE){
    signal input position[2];
    signal output range[3][2];

    // Can move forward one step
    component forwardPositions = ClampedBoardPosition();
    forwardPositions.position[0] = position[0];
    forwardPositions.position[1] = position[1] + 1;
    range[0] <== forwardPositions;
    
    // Can attack left
    component leftPositions = ClampedBoardPosition();
    leftPositions.position[0] = position[0] + 1;
    leftPositions.position[1] = position[1] - 1;
    range[1] <== leftPositions;

    // Can attack right
    component rightPositions = ClampedBoardPosition();
    rightPositions.position[0] = position[0] + 1;
    rightPositions.position[1] = position[1] + 1;
    range[2] <== rightPositions;
}

template PawnPiece(MAX_PIECES_PER_PLAYER) {
  // Private signals
  signal input piecePosition[2];
  signal input targetPosition[2];

  signal input positionOtherPieces[MAX_PIECES_PER_PLAYER - 1];
  
  // Public signals 
  signal input pieceId;
  signal output pieceCommitment; // A hash of the piece Id, and targetPosition
  signal output isValid; // boolean

  
}

component main {public [pieceId]} = PawnPiece(16);