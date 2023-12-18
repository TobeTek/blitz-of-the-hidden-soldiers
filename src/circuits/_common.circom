pragma circom 2.1.5;

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
