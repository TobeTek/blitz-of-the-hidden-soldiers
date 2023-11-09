pragma circom 2.0.0;

include "../_common.circom";
include "../../../node_modules/circomlib/circuits/mux1.circom";
include "../../../node_modules/circomlib/circuits/mimc.circom";
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

  signal input positionAllPieces[MAX_PIECES_PER_PLAYER][2];
  
  // Public signals 
  signal input pieceId;
  signal output pieceCommitment; // A hash of the piece Id, and targetPosition
  signal output isValid; // boolean

  component checkDuplicatePiecePositions = CheckDuplicatePiecePositions();
  checkDuplicatePiecePositions.piecePositions <== positionAllPieces;
  checkDuplicatePiecePositions.out === 0; // no duplicates

  component mimcHash = MultiMiMC7(MAX_PIECES_PER_PLAYER * 2, 2);
  mimcHash.k <== 256;
  
  for (var i = 0; i < MAX_PIECES_PER_PLAYER; i++){
    var pos[2] = positionAllPieces[i];
    var hashIndx = i * 2;
    mimcHash.in[hashIndx] <==  pos[0];
    mimcHash.in[hashIndx + 1] <== pos[1];
  }

  pieceCommitment <== mimcHash.out;
  isValid <== 1;
}

component main {public [pieceId]} = PawnPiece(16);