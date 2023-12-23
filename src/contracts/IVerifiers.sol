// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface IPieceMotion {
    function verifyProof(
        uint256[24] calldata _proof,
        uint256[2] calldata _pubSignals
    ) external view returns (bool);
}

interface IPlayerVision {
    function verifyProof(
        uint256[24] calldata _proof,
        uint256[65] calldata _pubSignals
    ) external view returns (bool);
}

interface IRevealBoardPosition {
    function verifyProof(
        uint256[24] calldata _proof,
        uint256[40] calldata _pubSignals
    ) external view returns (bool);
}

interface IHasher {
    function MiMCSponge(
        uint256 in_xL,
        uint256 in_xR
    ) external pure returns (uint256 xL, uint256 xR);
}
