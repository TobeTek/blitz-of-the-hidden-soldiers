pragma circom 2.0.0;

include "../common.circom";
include "../../../node_modules/circomlib/circuits/mux1.circom";

// calculate positions a chess can move from an origin position
// without considering other pieces on the board
function getPieceRange(position){
    return [[1,2], [3,4]];
}

// determine which positions are actually legal for a piece
// making sure they do not place two pieces on the same position
function filterLegalMovesFromRange(){
    return [[1,2], [3,4]];
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