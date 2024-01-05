// SPDX-License-Identifier: Apache-2.0
// Author: Tobe:)
pragma solidity ^0.8.0;

import {IPieceMotion, IPlayerVision, IRevealBoardPosition} from "./IVerifiers.sol";
import {PieceSelection} from "./GameManager.sol";
import {ChessPieceClass} from "./ChessPieceCollection.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// @title Coordinate struct represents the x and y coordinates of a point on a chessboard.
struct Coordinate {
    uint256 x; /// @dev x-coordinate value.
    uint256 y; /// @dev y-coordinate value.
}

/// @title Piece struct represents a chess piece with various attributes.
struct Piece {
    uint256 pieceId; /// @dev Unique identifier for the chess piece.
    uint256 tokenId; /// @dev Token ID associated with the chess piece.
    ChessPieceClass pieceClass; /// @dev Enum representing the class of the chess piece (e.g., Pawn, Rook).
    uint256 publicCommitment; /// @dev Public commitment value associated with the piece.
    Coordinate pieceCoords; /// @dev Coordinates of the chess piece on the board.
    bool isDead; /// @dev Flag indicating whether the chess piece is dead or alive.
}

/// @title ChessMove struct represents a chess move with relevant attributes.
struct ChessMove {
    uint256 pieceId; /// @dev Identifier of the chess piece making the move.
    uint256 publicCommitment; /// @dev Public commitment value associated with the move.
}

/// @title ChessGameState is an abstract contract defining the state variables and mappings for a chess game.
abstract contract ChessGameState {
    // --- Game State Flags ---

    /// @dev Flag indicating whether the game is over.
    bool public isGameOver;

    /// @dev Address of the winner of the chess game.
    address public winner;

    // --- Participants ---

    /// @dev Address of the contract owner.
    address public owner;

    /// @dev Address of the game manager.
    address public gameManagerAddress;

    /// @dev Address of the player controlling the white pieces.
    address public playerWhite;

    /// @dev Address of the player controlling the black pieces.
    address public playerBlack;

    // --- Verifier Contracts ---

    /// @dev Address of the contract responsible for verifying piece motions.
    address public pieceMotionVerifier;

    /// @dev Address of the contract responsible for verifying player vision.
    address public playerVisionVerifier;

    /// @dev Address of the contract responsible for revealing board positions.
    address public revealBoardPositionVerifier;

    // --- Player Moves and Positions ---

    /// @dev Address of the player currently making an attack.
    address public attackingPlayer;

    /// @dev Address of the player currently defending against an attack.
    address public defendingPlayer;

    /// @dev Mapping of player addresses to an array of chess moves.
    mapping(address => ChessMove[]) public playerMoves;

    /// @dev Mapping to track whether each player has reported their positions for the last play.
    mapping(address => bool) public hasReportedPositions;

    /// @dev Mapping to track whether each player has reported their vision.
    mapping(address => bool) public hasReportedVision;

    /// @dev Mapping to track whether each player has played their turn.
    mapping(address => bool) public hasPlayedTurn;

    // --- Board and Piece Information ---

    /// @dev Constant representing the width of the chessboard.
    uint public constant BOARD_WIDTH = 8;

    /// @dev Constant representing the height of the chessboard.
    uint public constant BOARD_HEIGHT = 8;

    /// @dev Constant representing the total number of squares on the chessboard.
    uint public constant TOTAL_SQUARES = BOARD_WIDTH * BOARD_HEIGHT;

    /// @dev Constant representing the number of pieces each player has.
    uint public constant PIECES_PER_PLAYER = 10;

    /// @dev Mapping of player addresses to their commitment for the game.
    mapping(address => bytes32) public playerCommitment;

    /// @dev Mapping of player addresses to their pieces on the chessboard.
    mapping(address => mapping(uint => Piece)) public playerPieces;

    /// @dev Mapping of player addresses to the coordinates of their pieces on the chessboard.
    mapping(address => mapping(uint => mapping(uint256 => uint256)))
        public pieceCoordinates;

    /// @dev Flattened array indicating which squares on the board a player can see.
    mapping(address => uint[TOTAL_SQUARES]) public playerBoardVision;

    /// @dev Mapping of player addresses to their selected pieces for the game.
    mapping(address => mapping(uint => PieceSelection))
        public playerAllocations;

    /// @dev Mapping of player addresses to whether their pieces have been captured.
    mapping(address => mapping(uint256 => bool)) public capturedPieces;

    // --- Token Information ---

    /// @dev Mapping of player addresses to the tally of tokens they possess.
    mapping(address => mapping(uint => uint)) public playerTokenTally;

    /// @dev Mapping of player addresses to the list of token IDs they possess.
    mapping(address => uint[]) public playerTokenIds;

    /// @dev Track if players have placed their pieces
    mapping(address => bool) public playerHasPlacedPieces;

    // --- Miscellaneous Constants ---

    /// @dev Constant representing an undefined coordinate value.
    uint public constant UNDEFINED_COORD = 1e10;
}

/// @title ChessGame is a Solidity contract representing the main logic for a chess game.
contract ChessGame is ChessGameState {
    /////////////////////////////////
    // EVENTS
    ////////////////////////////////

    /**
     * @dev Emitted when a player places all their pieces on the chess board.
     * @param player The address of the player making the move
     * @param pieceIds A list of piece IDs for the player.
     */
    event PlayerHasPlacedPieces(address indexed player, uint[] pieceIds);

    /**
     * @dev Emitted when a player makes a move in the chess game.
     * @param player The address of the player making the move.
     * @param move The details of the chess move.
     * @param playerIsWhite A boolean indicating whether the player is controlling the white pieces.
     */
    event MoveMade(address indexed game, address indexed player, ChessMove move, bool playerIsWhite);

    /**
     * @dev Emitted when a player reveals the position of a chess piece.
     * @param player The address of the player revealing the piece position.
     * @param pieceId The identifier of the revealed chess piece.
     * @param coord The coordinates of the revealed chess piece on the board.
     */
    event PiecePositionRevealed(
        address indexed game,
        address indexed player,
        uint256 indexed pieceId,
        Coordinate coord
    );

    /**
     * @dev Emitted when a chess piece is captured in the game.
     * @param pieceOwner The address of the player owning the captured piece.
     * @param piece The details of the captured chess piece.
     */
    event PieceCaptured(address pieceOwner, Piece piece);

    /**
     * @dev Emitted when the chess game is started.
     */
    event GameStarted();

    /**
     * @dev Emitted when the chess game is over, indicating the winner.
     * @param winner The address of the player who won the game.
     */
    event GameOver(address winner);

    /////////////////////////////////
    // INITIALIZATION / PRE-GAME
    ////////////////////////////////

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
        attackingPlayer = playerWhite;
        defendingPlayer = playerBlack;
    }

    /**
     * @dev Allows players to place their chess pieces on the board at the start of the game.
     * @param pieces An array of chess pieces to be placed by the player.
     * Requirements:
     * - The game must not have started.
     * - The correct number of pieces must be provided.
     * - The player has not already placed pieces.
     */
    function placePieces(Piece[] calldata pieces) public onlyPlayers {
        require(!isGameStarted(), "Pieces can only be placed at game start");
        require(
            pieces.length == PIECES_PER_PLAYER,
            "Invalid number of pieces provided"
        );
        require(
            !playerHasPlacedPieces[msg.sender],
            "Player has already placed pieces"
        );
        
        uint256[] memory pieceIds = new uint256[](PIECES_PER_PLAYER);

        for (uint i = 0; i < pieces.length; i++) {
            Piece calldata piece = pieces[i];
            uint tokenId = piece.tokenId;

            // Sanity check: Piece ID should not be zero
            require(piece.pieceId != 0, "Piece ID cannot be zero");
            pieceIds[i] = piece.pieceId;

            // Store the piece information
            playerTokenIds[msg.sender].push(tokenId);
            playerPieces[msg.sender][piece.pieceId] = piece;

            // Set initial position to undefined and mark the piece as alive
            playerPieces[msg.sender][piece.pieceId].pieceCoords = Coordinate(
                UNDEFINED_COORD,
                UNDEFINED_COORD
            );
            playerPieces[msg.sender][piece.pieceId].isDead = false;

            // Update token tally for the player
            playerTokenTally[msg.sender][tokenId]++;
        }

        // Check if placed pieces match player's allocation
        for (uint i = 0; i < playerTokenIds[msg.sender].length; i++) {
            uint tokenId = playerTokenIds[msg.sender][i];
            require(
                playerAllocations[msg.sender][tokenId].count >=
                    playerTokenTally[msg.sender][tokenId],
                "Placed pieces do not match player allocation."
            );
        }

        // Mark the player as having placed their pieces
        emit PlayerHasPlacedPieces(msg.sender, pieceIds);
        playerHasPlacedPieces[msg.sender] = true;
    }

    /**
     * @dev Sets the allocation of chess pieces for a specific player before the game starts.
     * @param player The address of the player for whom the allocations are set.
     * @param pieces An array of PieceSelection representing the chess piece allocations.
     * Requirements:
     * - The game must not have started.
     */
    function setPlayerAllocation(
        address player,
        PieceSelection[] calldata pieces
    ) public onlyAdmin {
        require(
            !isGameStarted(),
            "Allocation can only be set before the game starts"
        );

        for (uint i = 0; i < pieces.length; i++) {
            PieceSelection calldata piece = pieces[i];
            playerAllocations[player][piece.tokenId] = piece;
        }
    }

    ///////////////////////////////////////
    // GAMEPLAY
    //////////////////////////////////////

    /**
     * @dev Allows a player to make a move in the chess game.
     * @param _proof Array of 24 elements representing the proof for the move.
     * @param _pubSignals Array of 2 elements representing public signals for the move.
     * Requirements:
     * - The game must be in progress.
     * - It must be the player's turn to make a move.
     * - The player has not already played for this turn.
     * - The player must have the specified chess piece.
     * - The submitted proof must be valid.
     */
    function makeMove(
        uint256[24] calldata _proof,
        uint256[2] calldata _pubSignals
    ) external gameIsStarted onlyPlayers {
        uint256 publicCommitment = _pubSignals[0];
        uint256 pieceId = _pubSignals[1];

        require(
            isPlayerWhite(msg.sender) == isWhitePlayerTurn(),
            "It is not this player's turn to make a move"
        );
        require(
            !hasPlayedTurn[msg.sender],
            "You have already played for this turn"
        );
        require(
            playerHasPiece(msg.sender, pieceId),
            "Player does not have this piece"
        );

        require(
            IPieceMotion(pieceMotionVerifier).verifyProof(_proof, _pubSignals),
            "Invalid proof submitted"
        );

        // Update player's piece details and record the move
        playerPieces[msg.sender][pieceId].publicCommitment = publicCommitment;
        hasPlayedTurn[msg.sender] = true;
        playerMoves[msg.sender].push(ChessMove(pieceId, publicCommitment));

        // Emit the MoveMade event
        emit MoveMade(
            address(this),
            msg.sender,
            ChessMove(pieceId, publicCommitment),
            isPlayerWhite(msg.sender)
        );
    }

    /**
     * @dev Allows a player to report their vision of the chessboard during an attack.
     * @param _proof Array of 24 elements representing the proof for the vision report.
     * @param _pubSignals Array of 65 elements representing public signals for the vision report.
     * Requirements:
     * - The game must be in progress.
     * - The attacking player must have played their turn.
     * - The submitted proof must be valid.
     */
    function reportBoardVision(
        uint256[24] calldata _proof,
        uint256[65] calldata _pubSignals
    ) public gameIsStarted onlyPlayers attackingPlayerHasPlayed {
        require(
            IPlayerVision(playerVisionVerifier).verifyProof(
                _proof,
                _pubSignals
            ),
            "Invalid proof"
        );

        // Update player's board vision based on the reported signals
        for (uint i; i < TOTAL_SQUARES; i++) {
            playerBoardVision[msg.sender][i] = _pubSignals[i];
        }

        // Mark that the player has reported their vision
        hasReportedVision[msg.sender] = true;
    }

    /**
     * @dev Allows a player to report the positions of their chess pieces on the board.
     * @param _proof Array of 24 elements representing the proof for position reporting.
     * @param _pubSignals Array of 40 elements representing public signals for position reporting.
     * Requirements:
     * - The game must be in progress.
     * - The attacking player must have played their turn.
     * - The submitted proof must be valid.
     * - Both players must have reported their vision before positions can be reported.
     */
    function reportPositions(
        uint256[24] calldata _proof,
        uint256[40] calldata _pubSignals
    ) public gameIsStarted onlyPlayers attackingPlayerHasPlayed {
        require(
            IRevealBoardPosition(revealBoardPositionVerifier).verifyProof(
                _proof,
                _pubSignals
            ),
            "Invalid proof"
        );
        require(
            hasReportedVision[playerWhite] && hasReportedVision[playerBlack],
            "Both players must report their vision before positions can be reported"
        );

        // Extract piece IDs from the public signals
        uint256[] memory pieceIds = new uint256[](PIECES_PER_PLAYER);
        for (uint i = 0; i < PIECES_PER_PLAYER; i++) {
            pieceIds[i] = _pubSignals[i];
        }

        // Update positions based on the public signals
        for (uint i = PIECES_PER_PLAYER; i < PIECES_PER_PLAYER * 2; i += 2) {
            uint row = i;
            uint col = i + 1;
            uint pieceId = pieceIds[(i - PIECES_PER_PLAYER) / 2];
            uint xCoord = _pubSignals[row];
            uint yCoord = _pubSignals[col];

            require(
                (xCoord > 0) && (yCoord > 0),
                "Piece coordinates must be greater than 0"
            );

            Coordinate memory pieceCoord = Coordinate(xCoord, yCoord);
            playerPieces[msg.sender][pieceId].pieceCoords = pieceCoord;
            pieceCoordinates[msg.sender][xCoord][yCoord] = pieceId;

            // Emit PiecePositionRevealed event
            emit PiecePositionRevealed(address(this), msg.sender, pieceId, pieceCoord);
        }

        // Mark that the player has reported their positions
        hasReportedPositions[msg.sender] = true;
    }

    /**
     * @dev Marks the completion of a turn in the chess game.
     * Requirements:
     * - Both players must have reported their piece positions for the turn to be completed.
     * Effects:
     * - Captures opponent's pieces if applicable.
     * - Updates game state, declaring a winner if the opponent's king is captured.
     * - Resets various state variables for the next turn.
     */
    function markTurnAsOver() public onlyPlayers {
        require(
            hasReportedPositions[playerWhite] &&
                hasReportedPositions[playerBlack],
            "Turn can only be marked as completed when both players report piece positions"
        );

        // Iterate over the board to check for captures and update game state
        for (uint row = 0; row < BOARD_WIDTH; row++) {
            for (uint col = 0; col < BOARD_HEIGHT; col++) {
                uint attackingPieceId = pieceCoordinates[attackingPlayer][row][
                    col
                ];
                uint defendingPieceId = pieceCoordinates[defendingPlayer][row][
                    col
                ];

                bool attackingPieceIsDead = playerPieces[attackingPlayer][
                    attackingPieceId
                ].isDead;

                // Check if a piece was 'killed'
                if (
                    playerHasPiece(attackingPlayer, attackingPieceId) &&
                    playerHasPiece(defendingPlayer, defendingPieceId) &&
                    !attackingPieceIsDead
                ) {
                    // Capture the defending piece
                    capturedPieces[defendingPlayer][defendingPieceId] = true;
                    playerPieces[defendingPlayer][defendingPieceId]
                        .isDead = true;

                    Piece storage piece = playerPieces[defendingPlayer][
                        defendingPieceId
                    ];
                    emit PieceCaptured(defendingPlayer, piece);

                    // Check if a king is captured, ending the game
                    if (piece.pieceClass == ChessPieceClass.KING) {
                        isGameOver = true;
                        winner = attackingPlayer;
                        emit GameOver(attackingPlayer);
                    }
                }
            }
        }

        // Reset various state variables for the next turn
        resetGameState();
    }

    /**
     * @dev Resets various state variables for the next turn.
     * Effects:
     * - Resets reported positions and visions for both players.
     * - Swaps attacking and defending players.
     * - Resets played turn status for both players if the cycle is complete.
     */
    function resetGameState() internal {
        hasReportedPositions[playerWhite] = false;
        hasReportedPositions[playerBlack] = false;

        hasReportedVision[playerWhite] = false;
        hasReportedVision[playerBlack] = false;

        // Swap attacking and defending players
        (attackingPlayer, defendingPlayer) = (defendingPlayer, attackingPlayer);

        // Reset played turn status if the cycle is complete
        if (hasPlayedTurn[playerWhite] && hasPlayedTurn[playerBlack]) {
            hasPlayedTurn[playerWhite] = false;
            hasPlayedTurn[playerBlack] = false;
        }
    }

    /////////////////////////////////////
    // UTILITIES
    ////////////////////////////////////
    /**
     * @dev Changes the address of the PieceMotion verifier contract.
     * @param _contractAddress The new address of the PieceMotion verifier.
     * Requirements:
     * - Caller must be the contract owner.
     */
    function changePieceMotionVerifier(
        address _contractAddress
    ) public onlyAdmin {
        pieceMotionVerifier = _contractAddress;
    }

    /**
     * @dev Changes the address of the PlayerVision verifier contract.
     * @param _contractAddress The new address of the PlayerVision verifier.
     * Requirements:
     * - Caller must be the contract owner.
     */
    function changePlayerVisionVerifier(
        address _contractAddress
    ) public onlyAdmin {
        playerVisionVerifier = _contractAddress;
    }

    /**
     * @dev Changes the address of the RevealBoardPosition verifier contract.
     * @param _contractAddress The new address of the RevealBoardPosition verifier.
     * Requirements:
     * - Caller must be the contract owner.
     */
    function changeRevealBoardPositionVerifier(
        address _contractAddress
    ) public onlyAdmin {
        revealBoardPositionVerifier = _contractAddress;
    }

    /**
     * @dev Checks if a player owns a chess piece with the specified ID.
     * @param _player The address of the player to check.
     * @param _pieceId The ID of the chess piece to check ownership.
     * @return A boolean indicating whether the player owns the specified chess piece.
     */
    function playerHasPiece(
        address _player,
        uint256 _pieceId
    ) public view returns (bool) {
        // Returns true if the piece ID is not 0, indicating a defined chess piece.
        return playerPieces[_player][_pieceId].pieceId != 0;
    }

    /**
     * @dev Checks if the specified player is the white player in the chess game.
     * @param _address The address of the player to check.
     * @return A boolean indicating whether the player is the white player.
     */
    function isPlayerWhite(address _address) public view returns (bool) {
        return _address == playerWhite;
    }

    /**
     * @dev Checks if it is currently the white player's turn in the chess game.
     * @return A boolean indicating whether it is the white player's turn.
     */
    function isWhitePlayerTurn() public view returns (bool) {
        return
            playerMoves[playerBlack].length >= playerMoves[playerWhite].length;
    }

    /**
     * @dev Checks if the chess game has started by verifying if both players have placed their pieces on the board.
     * @return A boolean indicating whether the game has started.
     */
    function isGameStarted() public view returns (bool) {
        return
            playerHasPlacedPieces[playerWhite] &&
            playerHasPlacedPieces[playerBlack];
    }

    ///////////////////////////////////
    // MODIFIERS
    ///////////////////////////////////
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
        require(
            msg.sender == playerWhite || msg.sender == playerBlack,
            "Only players in this game can call this function"
        );
        _;
    }

    modifier attackingPlayerHasPlayed() {
        require(
            hasPlayedTurn[attackingPlayer],
            "Attacking player has not played for turn"
        );
        _;
    }
}
