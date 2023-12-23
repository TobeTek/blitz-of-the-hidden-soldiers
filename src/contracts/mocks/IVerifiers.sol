// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IPieceMotion, IPlayerVision, IRevealBoardPosition } from "../IVerifiers.sol";

contract MockPieceMotion is IPieceMotion {
    function verifyProof(
        uint256[24] calldata _proof,
        uint256[2] calldata _pubSignals
    ) external view returns (bool){
        return true;
    }
}

contract MockPlayerVision is IPlayerVision {
    function verifyProof(
        uint256[24] calldata _proof,
        uint256[65] calldata _pubSignals
    ) external view returns (bool){
        return true;
    }
}

contract MockRevealBoardPositions is IRevealBoardPosition {
    function verifyProof(
        uint256[24] calldata _proof,
        uint256[40] calldata _pubSignals
    ) external view returns (bool){
        return true;
    }
}