#!/bin/bash

process_file() {
    local file="$1"
    
    echo "Processing $file"
    echo "-----------------------"

    circom $file
}

# Find .circom files, excluding those starting with an underscore
find src/circuits -type f -name "*.circom" -not -name "_*" | while read -r file; do
    process_file "$file"
done