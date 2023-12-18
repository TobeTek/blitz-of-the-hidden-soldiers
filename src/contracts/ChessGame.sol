// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
// import "./Types.sol";

import {IPieceMotion, IPlayerVision, IRevealBoardPosition} from "./Verifiers.sol";
import {PieceSelection} from "./GameManager.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract ChessGame {
    int constant UNDEFINED_COORD = -1;

    struct Coordinate {
        int x;
        int y;
    }

    struct Piece {
        bytes32 pieceId;
        uint256 tokenId;
        uint256 pieceClass;
        bytes32 publicCommitment;
        Coordinate pieceCoords;
        bool isDead;
    }

    struct ChessMove {
        bytes32 pieceId;
        bytes32 publicCommitment;
    }

    // Has the game started? Have all players placed their pieces on the 'board'?
    mapping(address => bool) public playerHasPlacedPieces;

    function isGameStarted() public view {
        return
            playerHasPlacedPieces[playerWhite] &&
            playerHasPlacedPieces[playerBlack];
    }

    bool public isGameOver;

    // Admin accounts
    address public owner;
    address public gameManagerAddress;

    // Verifier addresses
    address public pieceMotionCircomAddress;
    address public playerVisionCircomAddress;
    address public revealBoardPositionCircomAddress;

    // Keep the traditional notation so it's easy to know what's going on
    address public playerWhite;
    address public playerBlack;

    mapping(address => ChessMove[]) public moves;

    // Have all players reported their positions for the last play
    mapping(address => bool) public hasReportedPositions;

    // Mapping of a Player to Piece IDs to Piece Positions
    // e.g { AliceAddress: { Pawn1 : {pieceType, publicCommitment ... }}}
    mapping(address => mapping(bytes32 => Piece)) public piecePositions;

    // A simple mapping of board coordinates (x, y) and the pieces on each one
    // for each player
    mapping(address => mapping(uint => mapping(uint256 => uint256))) pieceCoordinates;

    // The pieces a player can use in the particular game.
    // The value is set by the GameManager.placePieces function
    // Or a manual call from owner
    mapping(address => mapping(uint => PieceSelection)) playerAllocations;

    mapping(address => bytes32) public capturedPieces;

    modifier gameIsOver() {
        require(
            isGameOver,
            "The game must be over to be able to perform this action"
        );
        _;
    }

    modifier gameIsStarted() {
        require(
            isGameStarted,
            "The game must have started to be able to complete this action"
        );
        _;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == owner || msg.sender == gameManagerAddress,
            "This action can only be performed by the smart contract owner or game manager"
        );
        _;
    }

    modifier onlyPlayers() {
        bool isPlayer = msg.sender == playerWhite || msg.sender == playerBlack;
        require(isPlayer, "Only players in this game can call this function");
        _;
    }

    event MoveMade(address player, ChessMove move, bool playerIsWhite);
    event PieceCaptured(address pieceOwner, Piece piece);
    event GameStarted();
    event GameOver();

    constructor(address _playerWhite, address _playerBlack) {
        playerWhite = _playerWhite;
        playerBlack = _playerBlack;
    }

    function placePieces(Piece[] pieces) public onlyPlayers {
        mapping(uint => uint) tokenTally;
        for (uint i = 0; i < pieces.length; i++) {
            Piece piece = pieces[i];
            piecePositions[msg.sender][piece.pieceId] = piece;
            // The initial position should always be undefined, regardless of what the user provides
            piecePositions[msg.sender][piece.pieceId].pieceCoords = Coordinate(
                UNDEFINED_COORD,
                UNDEFINED_COORD
            );
            playerHasPlacedPieces[msg.sender] = true;
            tokenTally[piece.tokenId]++;
            require(
                playerAllocations[msg.sender][piece.tokenId] >=
                    tokenTally[piece.tokenId]++,
                "Placed pieces do not match player allocation."
            );
        }
    }

    function setPlayerAllocation(
        address player,
        PieceSelection[] pieces
    ) public onlyAdmin {
        for (uint i = 0; i < pieces.length; i++) {
            PieceSelection piece = pieces[i];
            playerAllocations[player][piece.tokenId] = piece;
        }
    }

    ///////////////////////////////////////
    // GAMEPLAY
    //////////////////////////////////////

    function makeMove(
        uint256[24] calldata _proof,
        uint256[2] calldata _pubSignals
    ) external gameIsStarted onlyPlayers {
        uint256 publicCommitment = _pubSignals[0];
        uint256 pieceId = _pubSignals[1];

        require(
            playerHasPiece(msg.sender, pieceId),
            "Player does not have a piece with this ID"
        );
        require(
            isPlayerWhite(msg.sender) == isWhitePlayerTurn,
            "It is not this player's turn to make a move"
        );

        bool isValidProof = IPieceMotion(pieceMotionCircomAddress).verifyProof(
            _proof,
            _pubSignals
        );
        require(isValidProof, "Invalid proof submitted");

        piecePositions[msg.sender][pieceId].publicCommitment = publicCommitment;
        moves[msg.sender].push(ChessMove(pieceId, publicCommitment));
        emit MoveMade(
            msg.sender,
            ChessMove(pieceId, publicCommitment),
            isPlayerWhite(msg.sender)
        );
    }

    function reportBoardVision() public gameIsStarted onlyPlayers {}

    function reportPositions() public gameIsStarted onlyPlayers {
        // Assert length of pieces is the same

        hasReportedPositions[msg.sender] = true;
    }

    // When both white and black have played their turns
    // Reset the
    function markTurnAsOver() public onlyPlayers {
        hasReportedPositions[playerWhite] = false;
        hasReportedPositions[playerBlack] = false;
    }

    /////////////////////////////////////
    // Change Verifier Addresses
    ////////////////////////////////////
    function changePieceMotionCircomAddress(
        address _contractAddress
    ) public onlyAdmin {
        pieceMotionCircomAddress = _contractAddress;
    }

    function changePlayerVisionCircomAddress(
        address _contractAddress
    ) public onlyAdmin {
        playerVisionCircomAddress = _contractAddress;
    }

    function changeRevealBoardPositionCircomAddress(
        address _contractAddress
    ) public onlyAdmin {
        revealBoardPositionCircomAddress = _contractAddress;
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

    function isWhitePlayerTurn() public view {
        return moves[playerBlack].length >= moves[playerWhite].length;
    }
}
