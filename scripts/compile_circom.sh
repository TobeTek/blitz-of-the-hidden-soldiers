#!/bin/bash

process_file() {
    local file="$1"
    
    echo "Processing $file"
    echo "-----------------------"

    circom $file --wasm --r1cs --sym -o compiled_circom

    circuit_name=$(basename $file) # Remove parent directories

    circuit_name=${circuit_name%.*} # Remove extension
    
    echo "Circuit Name: $circuit_name"

    
    # Create Final Verification Keys. Use PLONK protocol
    snarkjs plonk setup compiled_circom/$circuit_name.r1cs powersOfTau28_hez_final_15.ptau zkeys/$circuit_name.zkey

    # Export Solidity Verifier Smart Contract
    snarkjs zkey export solidityverifier zkeys/$circuit_name.zkey circom_verifiers/$circuit_name.Verifier.sol

}

# Create output directories
rm -rf compiled_circom
mkdir -p compiled_circom

rm -rf zkeys
mkdir -p zkeys

rm -rf circom_verifiers
mkdir -p circom_verifiers

# Find .circom files, excluding those starting with an underscore
find src/circuits -type  f -name "*.circom" -not -name "_*" | while read -r file; do
    process_file "$file"
done