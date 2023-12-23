#!/bin/bash

# Download powers_of_tau file
file_url="https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau"
destination_path="artifacts/powersOfTau28_hez_final_16.ptau"

# Check if the file exists
if [ ! -f "$destination_path" ]; then
    # If the file doesn't exist, download it
    curl -o "$destination_path" "$file_url"
    echo "powersOfTau28_hez_final_16.ptau downloaded successfully."
else
    # If the file exists, print a message
    echo "powersOfTau28_hez_final_16.ptau already exists. No need to download."
fi

process_file() {
    local file="$1"
    
    echo "Processing $file"
    echo "-----------------------"

    circom $file --wasm --r1cs --sym -o build/compiled_circom

    circuit_name=$(basename $file) # Remove parent directories

    circuit_name=${circuit_name%.*} # Remove extension
    
    echo "Circuit Name: $circuit_name"

    
    # Create Final Verification Keys. Use PLONK protocol
    snarkjs plonk setup build/compiled_circom/$circuit_name.r1cs artifacts/powersOfTau28_hez_final_16.ptau build/zkeys/$circuit_name.zkey

    # Export Solidity Verifier Smart Contract
    snarkjs zkey export solidityverifier build/zkeys/$circuit_name.zkey src/contracts/circom_verifiers/$circuit_name.Verifier.sol

    # Change the contract name from default to circom name
    # We can also achieve this by hooking into snarkjs and changing the template used
    verifier_contract="$circuit_name"PlonkVerifier
    
    echo "Verifier Contract Name: $verifier_contract"
    sed -i "s/PlonkVerifier/$verifier_contract/g" src/contracts/circom_verifiers/$circuit_name.Verifier.sol

}

# Create output directories
rm -rf build/compiled_circom
mkdir -p build/compiled_circom

rm -rf build/zkeys
mkdir -p build/zkeys

rm -rf src/contracts/circom_verifiers
mkdir -p src/contracts/circom_verifiers

# Find .circom files, excluding those starting with an underscore
find src/circuits -type  f -name "*.circom" -not -name "_*" | while read -r file; do
    process_file "$file"
done