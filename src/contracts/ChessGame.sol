// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./pieces/_Common.sol";
import "./_Types.sol";

contract ChessGame {
    // Has the game started? Have all players placed their pieces on the 'board'?
    bool public isGameStarted;

    mapping(bytes32 => GameTypes.PieceVerifierType) pieceVerifiers;

    // Keep the traditional notation so it's easy to know what's going on
    address public playerWhite;
    address public playerBlack;

    mapping(address => ChessTypes.ChessMove[]) public moves;

    // Mapping of a Player to Piece IDs to Piece Positions
    // e.g { AliceAddress: { Pawn1 : {pieceType, publicCommitment ... }}}
    mapping(address => mapping(bytes32 => ChessTypes.Piece))
        public piecePositions;

    mapping(address => bytes32) public capturedPieces;

    modifier onlyPlayers() {
        bool isPlayer = msg.sender == playerWhite || msg.sender == playerBlack;
        require(isPlayer, "Only players in this game can call this function");
        _;
    }

    event MoveMade(
        address player,
        ChessTypes.ChessMove move,
        bool playerIsWhite
    );
    event PieceCaptured(address pieceOwner, ChessTypes.Piece piece);
    event GameStarted();
    event GameOver();

    constructor(
        address _playerWhite,
        address _playerBlack,
        GameTypes.PieceVerifierType[] memory _pieceVerifiers
    ) {
        playerWhite = _playerWhite;
        playerBlack = _playerBlack;

        for (uint i = 0; i < _pieceVerifiers.length; i++) {
            GameTypes.PieceVerifierType memory verifier = _pieceVerifiers[i];
            pieceVerifiers[verifier.pieceType] = verifier;
        }
    }

    function makeMove(ChessTypes.ChessMove calldata move) external onlyPlayers {
        require(
            playerHasPiece(msg.sender, move.pieceId),
            "Player does not have a piece with this ID"
        );
        // NOTE: After the start of the game, players can no longer modify
        // information about their piece, beyond it's public commitment and position
        ChessTypes.Piece storage piece = piecePositions[msg.sender][move.pieceId];
        PieceVerifier verifier = PieceVerifier(pieceVerifiers[piece.pieceType].pieceVerifierContractAddress);
        verifier.verifyProof();

        moves[msg.sender].push(move);
        emit MoveMade(msg.sender, move, isPlayerWhite(msg.sender));
    }

    function reportPositions() public {
        // Assert length of pieces is the same
    }

    // Utility functions
    function playerHasPiece(
        address _player,
        bytes32 _pieceId
    ) public view returns (bool) {
        // Pieces that have not been defined
        // will have a piece ID of 0 in the struct
        return piecePositions[_player][_pieceId].pieceId == bytes32(0);
    }

    function isPlayerWhite(address _address) public view returns (bool) {
        return _address == playerWhite;
    }
}
