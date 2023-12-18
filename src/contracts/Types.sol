// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

int constant UNDEFINED_COORD = -1;

    struct Coordinate {
        int x;
        int y;
    }

    struct Piece {
        bytes32 pieceId;
        bytes32 pieceType;
        bytes32 publicCommitment;
        Coordinate pieceCoords;
        bool isDead;
    }

    struct ChessMove {
        bytes32 pieceId;
        bytes32 publicCommitment;
    }

    enum PieceType {
        KING,
        QUEEN,
        INFANTRY,
        PAWN,
        ARCHERS
    }

contract ChessTypes {
    

    function getPublicPieceIdentifier(
        PieceType _pieceType
    ) public pure returns (uint) {
        uint KING = 10;
        uint QUEEN = 20;
        uint INFANTRY = 30;
        uint PAWN = 40;
        uint ARCHERS = 50;

        if (_pieceType == PieceType.KING) {
            return KING;
        }
        if (_pieceType == PieceType.QUEEN) {
            return QUEEN;
        }
        if (_pieceType == PieceType.INFANTRY) {
            return INFANTRY;
        }
        if (_pieceType == PieceType.PAWN) {
            return PAWN;
        }
        if (_pieceType == PieceType.ARCHERS) {
            return ARCHERS;
        }

        revert("Unknown Piece Type");
    }
}
