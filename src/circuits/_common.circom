pragma circom 2.1.5;

include "../../node_modules/circomlib/circuits/mux1.circom";
include "../../node_modules/circomlib/circuits/mimc.circom";
include "../../node_modules/circomlib/circuits/mimcsponge.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/gates.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

// the implicit assumption of LessThan is both inputs are at most n bits
// so we need add range check for both inputs
template SafeLessThan(n) {
    assert(n <= 252);
    signal input in[2];
    signal output out;

    component n2b1 = Num2Bits(n);
    n2b1.in <== in[0];
    component n2b2 = Num2Bits(n);
    n2b2.in <== in[1];

    component n2b = Num2Bits(n+1);

    n2b.in <== in[0] + (1<<n) - in[1];

    out <== 1-n2b.out[n];
}

// N is the number of bits the input have.
// The MSF is the sign bit.
template SafeLessEqThan(n) {
    signal input in[2];
    signal output out;

    component lt = SafeLessThan(n);

    lt.in[0] <== in[0];
    lt.in[1] <== in[1]+1;
    lt.out ==> out;
}

// N is the number of bits the input have.
// The MSF is the sign bit.
template SafeGreaterThan(n) {
    signal input in[2];
    signal output out;

    component lt = SafeLessThan(n);

    lt.in[0] <== in[1];
    lt.in[1] <== in[0];
    lt.out ==> out;
}

// N is the number of bits the input have.
// The MSF is the sign bit.
template SafeGreaterEqThan(n) {
    signal input in[2];
    signal output out;

    component lt = SafeLessThan(n);

    lt.in[0] <== in[1];
    lt.in[1] <== in[0]+1;
    lt.out ==> out;
}

template Max() {
    signal input a;
    signal input b;
    signal output out;

    var BITSIZE = 64;
    
    component aIsGt = SafeGreaterThan(BITSIZE);
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
 
    component aIsGt = SafeLessThan(BITSIZE);
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

    component mimcCommitment = MiMCSponge(4, 220, 1);
    mimcCommitment.k <== 0;

    mimcCommitment.ins[0] <== pieceId;
    mimcCommitment.ins[1] <== pieceType;
    mimcCommitment.ins[2] <== piecePosition[0];
    mimcCommitment.ins[3] <== piecePosition[1];

    out <== mimcCommitment.outs[0];
}

template SelectArrayIndex(arrSize){
    var BITSIZE = 64;

    signal input arr[arrSize];
    signal input index;

    signal output out;

    // Index must be less than array size
    component indxLtArr = SafeLessThan(BITSIZE);
    indxLtArr.in[0] <== index;
    indxLtArr.in[1] <== arrSize;

    indxLtArr.out === 1;

    component isEqComp[arrSize];
    signal sums[arrSize];
    
    isEqComp[0] = IsEqual();
    isEqComp[0].in[0] <== 0;
    isEqComp[0].in[1] <== index;

    sums[0] <== arr[0] * isEqComp[0].out;

    for (var i = 1; i < arrSize; i++){
        isEqComp[i] = IsEqual();
        isEqComp[i].in[0] <== i;
        isEqComp[i].in[1] <== index;

        sums[i] <== sums[i - 1] + (arr[i] * isEqComp[i].out);
    }

    out <== sums[arrSize - 1];
}

template Select2DArrayIndex(dim1, dim2){
    var BITSIZE = 64;

    signal input arr[dim1][dim2];
    signal input index[2];

    signal output out;

    // Index must be less than array size
    component indx0LtArr = SafeLessThan(BITSIZE);
    indx0LtArr.in[0] <== index[0];
    indx0LtArr.in[1] <== dim1;
    indx0LtArr.out === 1;

    // Index must be less than array size
    component indx1LtArr = SafeLessThan(BITSIZE);
    indx1LtArr.in[0] <== index[1];
    indx1LtArr.in[1] <== dim2;
    indx1LtArr.out === 1;

    component isEqComp[dim1][dim2][2];
    signal sums[dim1 * dim2];
    signal isTargetIndx[dim1 * dim2];
    
    // First index 
    isEqComp[0][0][0] = IsEqual();
    isEqComp[0][0][0].in[0] <== 0;
    isEqComp[0][0][0].in[1] <== index[0];

    isEqComp[0][0][1] = IsEqual();
    isEqComp[0][0][1].in[0] <== 0;
    isEqComp[0][0][1].in[1] <== index[1];

    isTargetIndx[0] <== isEqComp[0][0][0].out * isEqComp[0][0][1].out;
    sums[0] <== arr[0][0] * isTargetIndx[0];

    // Iterate others
    var loopCounter = 1;
    
    for (var i = 0; i < dim1; i++){
        for (var j = 1; j < dim2; j++){
        
        
        isEqComp[i][j][0] = IsEqual();
        isEqComp[i][j][0].in[0] <== i;
        isEqComp[i][j][0].in[1] <== index[0];

        isEqComp[i][j][1] = IsEqual();
        isEqComp[i][j][1].in[0] <== j;
        isEqComp[i][j][1].in[1] <== index[1];

        isTargetIndx[loopCounter] <== isEqComp[i][j][0].out * isEqComp[i][j][1].out;

        sums[loopCounter] <== sums[loopCounter - 1] + (arr[i][j] * isTargetIndx[loopCounter]);

        loopCounter = loopCounter + 1;
        }
    }

    out <== sums[(dim1 * dim2) - 1];
}