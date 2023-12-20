// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {PieceSelection} from "./GameManager.sol";
import {ChessPieceProperties, ChessPieceClass} from "./ChessPieceCollection.sol";

interface IChessCollection is IERC1155 {
    function tokenProperties(
        uint256
    ) external view returns (ChessPieceProperties memory);
}

abstract contract ChessPieceFormation {
    // Address of the BoTHS NFT Collection Smart Contract
    address public chessCollectionAddress;

    // Standard Chess Formation
    mapping(ChessPieceClass => uint) standardChessFormation;

    // All Pawns Formation
    mapping(ChessPieceClass => uint) allPawnsFormation;

    // Verify that the right pieces were used in the right proportion
    function validatePieceFormation(
        PieceSelection[] memory pieces
    ) public view {
        uint kingClassTally;
        uint queenClassTally;
        uint bishopClassTally;
        uint knightClassTally;
        uint rookClassTally;
        uint pawnClassTally;

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

            // This could have been simplified using a mapping, but writing to state is expensive
            // and we expect this function to be called frequently
            if (piece.pieceClass == ChessPieceClass.KING) {
                kingClassTally += piece.count;
            } else if (piece.pieceClass == ChessPieceClass.QUEEN) {
                queenClassTally += piece.count;
            } else if (piece.pieceClass == ChessPieceClass.BISHOP) {
                bishopClassTally += piece.count;
            } else if (piece.pieceClass == ChessPieceClass.KNIGHT) {
                knightClassTally += piece.count;
            } else if (piece.pieceClass == ChessPieceClass.ROOK) {
                rookClassTally += piece.count;
            } else if (piece.pieceClass == ChessPieceClass.PAWN) {
                pawnClassTally += piece.count;
            } else {
                revert("Unknown/unsupported piece class");
            }
        }

        // TODO: Support more formations
        require(
            isValidStandardChessFormation(
                kingClassTally,
                queenClassTally,
                bishopClassTally,
                knightClassTally,
                rookClassTally,
                pawnClassTally
            ) ||
                isValidAllPawnFormation(
                    kingClassTally,
                    queenClassTally,
                    bishopClassTally,
                    knightClassTally,
                    rookClassTally,
                    pawnClassTally
                ),
            "This piece formation is not allowed."
        );
    }

    function isValidStandardChessFormation(
        uint kingClassTally,
        uint queenClassTally,
        uint bishopClassTally,
        uint knightClassTally,
        uint rookClassTally,
        uint pawnClassTally
    ) public pure returns (bool) {
        return ((kingClassTally == 1) &&
            (queenClassTally == 1) &&
            (bishopClassTally == 2) &&
            (knightClassTally == 2) &&
            (rookClassTally == 2) &&
            (pawnClassTally == 8));
    }

    function isValidAllPawnFormation(
        uint kingClassTally,
        uint queenClassTally,
        uint bishopClassTally,
        uint knightClassTally,
        uint rookClassTally,
        uint pawnClassTally
    ) public pure returns (bool) {
        return ((kingClassTally == 1) &&
            (queenClassTally == 1) &&
            (bishopClassTally == 0) &&
            (knightClassTally == 0) &&
            (rookClassTally == 0) &&
            (pawnClassTally == 14));
    }
}
