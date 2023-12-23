// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {PieceSelection} from "./GameManager.sol";
import {ChessPieceProperties, ChessPieceClass, IChessCollection} from "./ChessPieceCollection.sol";

/**
 * @title ChessPieceFormation
 * @dev A contract handling the validation of chess piece formations.
 */
abstract contract ChessPieceFormation {
    // Address of the BoTHS NFT Collection Smart Contract
    address public chessCollectionAddress;

    /**
     * @dev Validates that the given piece formation is allowed.
     * @param pieces The array of PieceSelection representing the chess pieces.
     * Requirements:
     * - Input pieceClass and actual pieceClass must match for each piece.
     * - The piece formation must be either a valid standard chess formation or a valid all-pawn formation.
     */
    function validatePieceFormation(
        PieceSelection[] memory pieces
    ) public view {
        uint[6] memory classTally;

        for (uint i = 0; i < pieces.length; i++) {
            PieceSelection memory piece = pieces[i];
            IChessCollection chessCollection = IChessCollection(
                chessCollectionAddress
            );
            ChessPieceProperties memory pieceProperties = chessCollection
                .tokenProperties(piece.tokenId);

            require(
                piece.pieceClass == pieceProperties.pieceClass,
                "Input pieceClass and actual pieceClass do not match."
            );

            uint pieceClassIndex = uint(piece.pieceClass);
            require(pieceClassIndex < 6, "Unknown/unsupported piece class");

            classTally[pieceClassIndex] += piece.count;
        }

        require(
            isValidStandardChessFormation(classTally) ||
                isValidAllPawnFormation(classTally),
            "This piece formation is not allowed."
        );
    }

    /**
     * @dev Checks if the given class tally represents a valid standard chess formation.
     * @param classTally An array representing the tally of each chess piece class.
     * @return A boolean indicating whether the formation is valid.
     */
    function isValidStandardChessFormation(
        uint[6] memory classTally
    ) public pure returns (bool) {
        return ((classTally[uint(ChessPieceClass.KING)] == 1) &&
            (classTally[uint(ChessPieceClass.QUEEN)] == 1) &&
            (classTally[uint(ChessPieceClass.BISHOP)] == 1) &&
            (classTally[uint(ChessPieceClass.KNIGHT)] == 1) &&
            (classTally[uint(ChessPieceClass.ROOK)] == 1) &&
            (classTally[uint(ChessPieceClass.PAWN)] == 5));
    }

    /**
     * @dev Checks if the given class tally represents a valid all-pawn formation.
     * @param classTally An array representing the tally of each chess piece class.
     * @return A boolean indicating whether the formation is valid.
     */
    function isValidAllPawnFormation(
        uint[6] memory classTally
    ) public pure returns (bool) {
        return ((classTally[uint(ChessPieceClass.KING)] == 1) &&
            (classTally[uint(ChessPieceClass.QUEEN)] == 1) &&
            (classTally[uint(ChessPieceClass.BISHOP)] == 0) &&
            (classTally[uint(ChessPieceClass.KNIGHT)] == 0) &&
            (classTally[uint(ChessPieceClass.ROOK)] == 0) &&
            (classTally[uint(ChessPieceClass.PAWN)] == 8));
    }
}
