// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./ChessGame.sol";
import "./ChessPieceCollection.sol";

import "hardhat/console.sol";

import {ChessPieceFormation} from "./ChessPieceFormations.sol";
import {ChessPieceProperties, ChessPieceClass, IChessCollection} from "./ChessPieceCollection.sol";

/**
 * @dev Represents the selection of a chess piece, including its class, token ID, and count.
 */
struct PieceSelection {
    ChessPieceClass pieceClass; // The class or type of the chess piece.
    uint256 tokenId; // The unique identifier associated with the chess piece.
    uint256 count; // The number of instances of this chess piece selected.
}

/**
 * @dev Represents the essential data for a chess game, including the addresses of the white and black players
 * and a flag indicating whether the game is over.
 */
struct GameData {
    address playerWhite; // The Ethereum address of the player controlling the white pieces.
    address playerBlack; // The Ethereum address of the player controlling the black pieces.
    bool isOver; // Is this particular game over?
}

/**
 * @title GameManager
 * @dev Manages the creation of chess games between players and locks pieces currently in the game.
 * Inherits functionality for managing chess piece formations.
 */
contract GameManager is ChessPieceFormation {
    /**
     * @dev Emitted when a new chess game is created between players.
     */
    event GameCreated(
        address gameAddress,
        address indexed playerWhite,
        address indexed playerBlack
    );

    /**
     * @dev Emitted when a player has selected their chess pieces for the game.
     */
    event PlayerSelectedPieces(
        address indexed gameAddress,
        address indexed player,
        PieceSelection[] selection
    );

    // Admin address
    address public owner;

    // Store what games are currently in play
    mapping(address => GameData) games;

    // Store the count of games a player is currently playing
    mapping(address => uint) playerActiveGames;

    // We lock players' pieces when they are currently in use in a match
    mapping(address => mapping(uint256 => uint256)) public lockedTokens;

    constructor(address _owner, address _chessCollectionAddress) {
        owner = _owner;
        chessCollectionAddress = _chessCollectionAddress;
    }

    /**
     * @dev Creates a new chess game between two players.
     * @param playerWhite The address of the player controlling the white pieces.
     * @param playerBlack The address of the player controlling the black pieces.
     * @return The address of the newly created chess game.
     */
    function createChessGame(
        address playerWhite,
        address playerBlack
    ) public returns (address) {
        ChessGame game = new ChessGame(
            owner,
            address(this),
            playerWhite,
            playerBlack
        );

        // Store game data
        games[address(game)] = GameData(playerWhite, playerBlack, false);

        // Increment active game counts for both players
        playerActiveGames[playerWhite]++;
        playerActiveGames[playerBlack]++;
        console.log(
            "Creating game: gameAddress: %s playerWhite: %s playerBlack %s",
            address(game),
            playerWhite,
            playerBlack
        );

        emit GameCreated(address(game), playerWhite, playerBlack);
        return address(game);
    }

    /**
     * @dev Places selected chess pieces onto the chessboard in the specified game.
     * @param gameAddress The address of the chess game where pieces will be placed.
     * @param pieces An array of PieceSelection structs representing the player's chosen chess pieces.
     * Requirements:
     * - The player must be part of the specified chess game.
     * - The selected piece formation must be valid.
     * - The player must have sufficient token balance for the selected pieces.
     * Effects:
     * - Updates the chess game with the player's selected piece allocation.
     */
    function setPlayerAllocation(
        address gameAddress,
        PieceSelection[] memory pieces
    ) public isPlayerInGame(gameAddress) {
        // Validate the piece formation and user's token balance
        validatePieceFormation(pieces);
        validateUserHasTokenBalance(msg.sender, pieces);

        // Set the player's piece allocation in the specified chess game
        ChessGame game = ChessGame(gameAddress);
        game.setPlayerAllocation(msg.sender, pieces);

        emit PlayerSelectedPieces(gameAddress, msg.sender, pieces);
    }

    /**
     * @dev Validates that the player has the required token balance for the specified chess pieces.
     * @param player The address of the player to validate.
     * @param pieces An array of PieceSelection structs representing the chess pieces to validate.
     * Requirements:
     * - The player must have the required balance for each specified chess piece.
     * - The pieces must either be owned by the player or be default pieces available to everyone.
     * Effects:
     * - Locks the player's chess pieces to prevent them from being sold while in play.
     */
    function validateUserHasTokenBalance(
        address player,
        PieceSelection[] memory pieces
    ) public {
        IChessCollection chessCollection = IChessCollection(
            chessCollectionAddress
        );

        // Confirm player has all specified pieces
        for (uint i; i < pieces.length; i++) {
            PieceSelection memory piece = pieces[i];

            // Check player's balance for the specified piece
            uint256 playerBalance = chessCollection.balanceOf(
                player,
                piece.tokenId
            );

            // We only check if either the player as an entity has that number of pieces.
            // We can also check if a combination of both the player's balance and the default pieceset
            // can meet the desired number, however, generally, we want to prevent such 'mixing' of ownership
            if (!chessCollection.isDefaultPiece(piece.tokenId)) {
                uint256 lockedPlayerTokens = lockedTokens[player][
                    piece.tokenId
                ];
                bool playerHasPieces = (playerBalance + lockedPlayerTokens) >=
                    piece.count;
                require(
                    playerHasPieces,
                    "User must have the specified pieceType or it must be a default piece available to everyone"
                );

                // Lock the pieces to prevent them from being sold while in play
                if (lockedPlayerTokens < piece.count) {
                    lockPlayerTokens(
                        player,
                        piece.tokenId,
                        piece.count - lockedPlayerTokens
                    );
                }
            }
        }
    }

    /**
     * @dev Locks a specified amount of chess pieces from the player's collection.
     * @param player The address of the player from whom the pieces will be locked.
     * @param tokenId The ID of the chess piece to be locked.
     * @param lockAmount The number of pieces to be locked.
     * Effects:
     * - Transfers the specified amount of chess pieces from the player to this contract.
     * - Increases the locked token balance for the player.
     */
    function lockPlayerTokens(
        address player,
        uint256 tokenId,
        uint256 lockAmount
    ) public {
        IChessCollection chessCollection = IChessCollection(
            chessCollectionAddress
        );

        // Assume that the sender has already approved this contract
        chessCollection.safeTransferFrom(
            player,
            address(this),
            tokenId,
            lockAmount,
            ""
        );

        // Increase the locked token balance for the player
        lockedTokens[player][tokenId] += lockAmount;
    }

    /**
     * @dev Unlocks a specified amount of previously locked chess pieces and transfers them back to the player.
     * @param player The address of the player to whom the pieces will be unlocked.
     * @param tokenId The ID of the chess piece to be unlocked.
     * @param unlockAmount The number of pieces to be unlocked.
     * Requirements:
     * - Only the token owner or the smart contract owner can perform this action.
     * - The player must have concluded all ongoing games before unlocking pieces.
     * Effects:
     * - Decreases the locked token balance for the player.
     * - Transfers the specified amount of chess pieces back to the player.
     */
    function unlockPlayerTokens(
        address player,
        uint256 tokenId,
        uint256 unlockAmount
    ) public {
        require(
            playerActiveGames[player] == 0,
            "Player must conclude all ongoing games before unlocking pieces"
        );
        require(unlockAmount > 0, "Unlock amount must be greater than zero");
        require(
            lockedTokens[player][tokenId] >= unlockAmount,
            "Insufficient lock balance to perform this action"
        );

        // Decrease the locked token balance for the player
        lockedTokens[player][tokenId] -= unlockAmount;

        IChessCollection chessCollection = IChessCollection(
            chessCollectionAddress
        );

        // Transfer the unlocked pieces back to the player
        chessCollection.safeTransferFrom(
            address(this),
            player,
            tokenId,
            unlockAmount,
            ""
        );
    }

    /**
     * @dev Marks a chess game as concluded and updates player game counts.
     * @param gameAddress The address of the chess game to be marked as over.
     * Requirements:
     * - The specified chess game must have ended.
     * - The chess game has not been marked as concluded before.
     * Effects:
     * - Updates the game state to be marked as over.
     * - Decreases the active game counts for both players.
     */
    function markGameAsOver(address gameAddress) public {
        ChessGame game = ChessGame(gameAddress);
        require(game.isGameOver(), "This chess game has not yet ended");
        require(
            !games[gameAddress].isOver,
            "This chess game has already been marked as concluded"
        );

        // Mark the chess game as over
        games[gameAddress].isOver = true;

        // Update player game counts
        address playerWhite = games[gameAddress].playerWhite;
        address playerBlack = games[gameAddress].playerBlack;
        playerActiveGames[playerWhite]--;
        playerActiveGames[playerBlack]--;
    }

    /**
     * @dev Updates the address of the ChessCollection contract.
     * @param _chessCollectionAddress The new address of the ChessCollection contract.
     * Requirements:
     * - Only the owner of this contract can update the ChessCollection address.
     * Effects:
     * - Updates the ChessCollection contract address.
     */
    function updateChessCollectionAddress(
        address _chessCollectionAddress
    ) public onlyOwner {
        chessCollectionAddress = _chessCollectionAddress;
    }

    modifier isPlayerInGame(address gameAddress) {
        GameData storage game = games[gameAddress];
        require(
            (game.playerWhite == msg.sender) ||
                (game.playerBlack == msg.sender),
            "You must be a player in the chess game to perform this action"
        );
        _;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only smart contract owner can invoke this function"
        );
        _;
    }

    // * receive function
    receive() external payable {}

    // * fallback function
    fallback() external {}
}
