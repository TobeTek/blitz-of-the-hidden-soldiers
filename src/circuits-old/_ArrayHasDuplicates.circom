pragma circom  2.1.0;

include "../../node_modules/circomlib/circuits/comparators.circom";

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


// component main = ArrayHasDuplicates(4, 3);

/*
INPUT = {
    "arr": [
        ["1", "2", "0"], 
        ["1", "2", "1"],
        ["3", "4", "0"], 
        ["5", "6", "0"]
    ]
}
*/