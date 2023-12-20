// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {IPieceMotion, IPlayerVision, IRevealBoardPosition} from "./Verifiers.sol";
import {PieceSelection} from "./GameManager.sol";
import {ChessPieceClass} from "./ChessPieceCollection.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

struct Coordinate {
    uint256 x;
    uint256 y;
}

struct Piece {
    uint256 pieceId;
    uint256 tokenId;
    ChessPieceClass pieceClass;
    uint256 publicCommitment;
    Coordinate pieceCoords;
    bool isDead;
}

struct ChessMove {
    uint256 pieceId;
    uint256 publicCommitment;
}

contract ChessGame {
    // Has the game started? Have all players placed their pieces on the 'board'?
    mapping(address => bool) public playerHasPlacedPieces;

    function isGameStarted() public view returns (bool) {
        return
            playerHasPlacedPieces[playerWhite] &&
            playerHasPlacedPieces[playerBlack];
    }

    address public winner;
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

    // Have all players made a move for the current turn
    mapping(address => bool) public hasPlayedTurn;

    // Have all players reported their positions for the last play
    mapping(address => bool) public hasReportedPositions;

    uint public constant BOARD_WIDTH = 8;
    uint public constant BOARD_HEIGHT = 8;
    uint public constant NO_BOARD_SQUARES = BOARD_WIDTH * BOARD_HEIGHT;
    uint public constant NUMBER_OF_PIECES = 16; // per player

    mapping(address => bytes32) playerCommitment;

    // Mapping of a Player to Piece IDs to Piece Positions
    // e.g { AliceAddress: { Pawn1 : {pieceType, publicCommitment ... }}}
    mapping(address => mapping(uint => Piece)) public playerPieces;

    // A simple mapping of board coordinates (x, y) and the pieces on each one
    // for each player
    mapping(address => mapping(uint => mapping(uint256 => uint256))) pieceCoordinates;

    // Flattened array of which squares a player can see
    mapping(address => uint[NO_BOARD_SQUARES]) playerBoardVision;

    // The pieces a player can use in the particular game.
    mapping(address => mapping(uint => PieceSelection))
        public playerAllocations;

    mapping(address => mapping(uint256 => bool)) public capturedPieces;

    modifier gameIsOver() {
        require(
            isGameOver,
            "The game must be over to be able to perform this action"
        );
        _;
    }

    modifier gameIsStarted() {
        require(
            isGameStarted(),
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
    event PiecePositionRevealed(
        address player,
        uint256 pieceId,
        Coordinate coord
    );
    event PieceCaptured(address pieceOwner, Piece piece);
    event GameStarted();
    event GameOver(address winner);

    constructor(
        address _owner,
        address _gameManagerAddress,
        address _playerWhite,
        address _playerBlack
    ) {
        owner = _owner;
        gameManagerAddress = _gameManagerAddress;
        playerWhite = _playerWhite;
        playerBlack = _playerBlack;
    }

    mapping(address => mapping(uint => uint)) playerTokenTally;

    mapping(address => uint[]) playerTokenIds;

    function placePieces(Piece[] calldata pieces) public onlyPlayers {
        require(!isGameStarted(), "Pieces can only be placed at game start");

        for (uint i = 0; i < pieces.length; i++) {
            Piece calldata piece = pieces[i];
            playerTokenIds[msg.sender].push(piece.tokenId);

            // Sanity check. To avoid conflicts with the default state
            require(piece.pieceId != 0, "Piece ID can not be equal to zero");

            playerPieces[msg.sender][piece.pieceId] = piece;

            // The initial position should always be undefined, regardless of what the user provides
            playerPieces[msg.sender][piece.pieceId].pieceCoords = Coordinate(
                UNDEFINED_COORD,
                UNDEFINED_COORD
            );
            // Pieces can't be 'born' dead. Can they?
            playerPieces[msg.sender][piece.pieceId].isDead = false;

            playerHasPlacedPieces[msg.sender] = true;
            playerTokenTally[msg.sender][piece.tokenId]++;
        }

        for (uint i = 0; i < playerTokenIds[msg.sender].length; i++) {
            uint tokenId = playerTokenIds[msg.sender][i];
            require(
                playerAllocations[msg.sender][tokenId].count >=
                    playerTokenTally[msg.sender][tokenId],
                "Placed pieces do not match player allocation."
            );
        }
    }

    function setPlayerAllocation(
        address player,
        PieceSelection[] calldata pieces
    ) public onlyAdmin {
        require(
            !isGameStarted(),
            "Action can not be performed after game has started"
        );
        for (uint i = 0; i < pieces.length; i++) {
            PieceSelection calldata piece = pieces[i];
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
            isPlayerWhite(msg.sender) == isWhitePlayerTurn(),
            "It is not this player's turn to make a move"
        );

        require(
            IPieceMotion(pieceMotionCircomAddress).verifyProof(
                _proof,
                _pubSignals
            ),
            "Invalid proof submitted"
        );

        playerPieces[msg.sender][pieceId].publicCommitment = publicCommitment;
        moves[msg.sender].push(ChessMove(pieceId, publicCommitment));
        emit MoveMade(
            msg.sender,
            ChessMove(pieceId, publicCommitment),
            isPlayerWhite(msg.sender)
        );
    }

    function reportBoardVision(
        uint256[24] calldata _proof,
        uint256[65] calldata _pubSignals
    ) public gameIsStarted onlyPlayers {
        require(
            isPlayerWhite(msg.sender) == isWhitePlayerTurn(),
            "It is not this player's turn to make a move"
        );
        IPlayerVision(playerVisionCircomAddress).verifyProof(
            _proof,
            _pubSignals
        );

        for (uint i; i < NO_BOARD_SQUARES; i++) {
            playerBoardVision[msg.sender][i] = _pubSignals[i];
        }
    }

    function reportPositions(
        uint256[24] calldata _proof,
        uint256[64] calldata _pubSignals
    ) public gameIsStarted onlyPlayers {
        require(
            IRevealBoardPosition(revealBoardPositionCircomAddress).verifyProof(
                _proof,
                _pubSignals
            ),
            "Invalid proof"
        );

        uint256[] memory pieceIds;
        for (uint i = 0; i < NUMBER_OF_PIECES; i++) {
            pieceIds[i] = _pubSignals[i];
        }

        // Two coordinate values are stored for each piece
        uint256[] memory pieceCoords;

        uint counter = 0;
        for (uint i = NUMBER_OF_PIECES; i < NUMBER_OF_PIECES * 2; i += 2) {
            uint row = i;
            uint col = i + 1;
            uint pieceId = pieceIds[counter];
            uint xCoord = _pubSignals[row];
            uint yCoord = pieceCoords[col];

            Coordinate memory pieceCoord = Coordinate(xCoord, yCoord);
            playerPieces[msg.sender][pieceId].pieceCoords = pieceCoord;
            pieceCoordinates[msg.sender][xCoord][yCoord] = pieceId;

            counter++;

            emit PiecePositionRevealed(msg.sender, pieceId, pieceCoord);
        }

        hasReportedPositions[msg.sender] = true;
    }

    function markTurnAsOver() public onlyPlayers {
        require(
            hasReportedPositions[playerWhite] &&
                hasReportedPositions[playerBlack],
            "A player's turn can not be marked as completed till both players have reported piece positions"
        );

        // Check if the last move was a kill
        address attackingPlayer;
        address defendingPlayer;

        if (isWhitePlayerTurn()) {
            attackingPlayer = playerWhite;
            defendingPlayer = playerBlack;
        } else {
            attackingPlayer = playerBlack;
            defendingPlayer = playerWhite;
        }

        for (uint row = 0; row < BOARD_WIDTH; row++) {
            for (uint col = 0; col < BOARD_HEIGHT; col++) {
                uint attackingPieceId = pieceCoordinates[attackingPlayer][row][
                    col
                ];
                uint defendingPieceId = pieceCoordinates[defendingPlayer][row][
                    col
                ];
                // A piece was 'killed'!
                if (
                    playerHasPiece(attackingPlayer, attackingPieceId) &&
                    playerHasPiece(defendingPlayer, defendingPieceId)
                ) {
                    capturedPieces[defendingPlayer][defendingPieceId] = true;
                    playerPieces[defendingPlayer][defendingPieceId]
                        .isDead = true;

                    Piece storage piece = playerPieces[defendingPlayer][
                        defendingPieceId
                    ];
                    emit PieceCaptured(defendingPlayer, piece);

                    // Once a king is captured, game over!
                    if (piece.pieceClass == ChessPieceClass.KING) {
                        isGameOver = true;
                        winner = attackingPlayer;
                        emit GameOver(attackingPlayer);
                    }
                }
            }
        }

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
        uint256 _pieceId
    ) public view returns (bool) {
        // Pieces that have not been defined
        // will have a piece ID of 0 in the struct
        return playerPieces[_player][_pieceId].pieceId == uint256(0);
    }

    function isPlayerWhite(address _address) public view returns (bool) {
        return _address == playerWhite;
    }

    function isWhitePlayerTurn() public view returns (bool) {
        return moves[playerBlack].length >= moves[playerWhite].length;
    }

    uint public constant UNDEFINED_COORD = 1e10;
}
