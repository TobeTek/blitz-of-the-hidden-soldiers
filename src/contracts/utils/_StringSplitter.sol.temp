// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StringSplitter {
    function splitString(string memory _input) public pure returns (uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[1] memory input) {
        // Split the input string by spaces
        string[] memory parts = split(_input, " ");

        // Convert the string parts to integers and assign them to the variables
        require(parts.length == 7, "Input does not have the expected number of parts.");

        a[0] = parseInt(parts[0]);
        a[1] = parseInt(parts[1]);

        b[0][0] = parseInt(parts[2]);
        b[0][1] = parseInt(parts[3]);
        b[1][0] = parseInt(parts[4]);
        b[1][1] = parseInt(parts[5]);

        c[0] = parseInt(parts[6]);

        input[0] = parseInt(parts[0]);

        return (a, b, c, input);
    }

    // Utility function to split a string by a delimiter
    function split(string memory input, string memory delimiter) internal pure returns (string[] memory) {
        bytes memory inputBytes = bytes(input);
        bytes memory delimiterBytes = bytes(delimiter);

        uint numParts = 1;

        for (uint i = 0; i < inputBytes.length; i++) {
            if (inputBytes[i] == delimiterBytes[0]) {
                numParts++;
            }
        }

        string[] memory parts = new string[](numParts);
        uint partCounter = 0;
        string memory currentPart = "";

        for (uint i = 0; i < inputBytes.length; i++) {
            if (inputBytes[i] == delimiterBytes[0]) {
                parts[partCounter] = currentPart;
                partCounter++;
                currentPart = "";
            } else {
                currentPart = string(abi.encodePacked(currentPart, inputBytes[i]));
            }
        }

        parts[partCounter] = currentPart;
        return parts;
    }

    // Utility function to convert a string to an integer
    function parseInt(string memory value) internal pure returns (uint) {
        uint result = 0;
        bytes memory b = bytes(value);
        for (uint i = 0; i < b.length; i++) {
            if (b[i] >= 48 && b[i] <= 57) {
                result = result * 10 + (uint(b[i]) - 48);
            }
        }
        return result;
    }
}

// For Solidity 0.8.6
function stringToUint(string memory s) public pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
