// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./ChessGame.sol";
import "./ChessPieceCollection.sol";

import {ChessPieceFormation} from "./ChessPieceFormations.sol";
import {ChessPieceProperties, ChessPieceClass} from "./ChessPieceCollection.sol";

struct PieceSelection {
    ChessPieceClass pieceClass;
    uint256 tokenId;
    uint256 count;
}

interface IChessCollection is IERC1155 {
    function tokenProperties(
        uint256
    ) external view returns (ChessPieceProperties memory);
}

// Manage creating games between players
// Lock pieces currently in game
contract GameManager is ChessPieceFormation {
    struct GameData {
        address playerWhite;
        address playerBlack;
        bool isOver;
    }

    event GameCreated();

    event PlayerSelectedPieces();

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

    function updateChessCollectionAddress(
        address _chessCollectionAddress
    ) public onlyOwner {
        chessCollectionAddress = _chessCollectionAddress;
    }

    function createChessGame(
        address playerWhite,
        address playerBlack
    ) public returns (address) {
        ChessGame game = new ChessGame(owner, address(this), playerWhite, playerBlack);
        games[address(game)] = GameData(playerWhite, playerBlack, false);

        playerActiveGames[playerWhite]++;
        playerActiveGames[playerBlack]++;

        return address(game);
    }

    function placePieces(
        address gameAddress,
        PieceSelection[] memory pieces
    ) public isPlayerInGame(gameAddress) {
        validatePieceFormation(pieces);
        validateUserHasTokenBalance(msg.sender, pieces);

        ChessGame game = ChessGame(gameAddress);
        game.setPlayerAllocation(msg.sender, pieces);
    }

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
            address[] memory accounts;
            accounts[0] = player;
            accounts[1] = address(0);

            uint256[] memory tokenIds;
            tokenIds[0] = piece.tokenId;
            tokenIds[1] = piece.tokenId;

            uint256[] memory balances = chessCollection.balanceOfBatch(
                accounts,
                tokenIds
            );

            // We only check if either the player as an entity has that number of pieces.
            // We can also check if a combination of both the player's balance and the default pieceset
            // can meet the desired number, however, generally, we want to prevent such 'mixing' of ownership
            uint256 lockedPlayerTokens = lockedTokens[player][piece.tokenId];
            bool playerHasPieces = (balances[0] + lockedPlayerTokens) >=
                piece.count;
            // Only a single record of a default piece is stored
            bool isDefaultPieces = balances[1] >= piece.count;

            require(
                playerHasPieces || isDefaultPieces,
                "User must have the specified pieceType or it must be a default piece available to everyone"
            );

            // Lock the pieces so they can't be sold while in play
            // TODO: Switch to using batchTransferFrom
            uint256 lockAmount = piece.count - lockedPlayerTokens;
            if (playerHasPieces && (lockAmount > 0)) {
                lockPlayerTokens(player, piece.tokenId, lockAmount);
            }
        }
    }

    function markGameAsOver(address gameAddress) public {
        ChessGame game = ChessGame(gameAddress);
        require(game.isGameOver(), "This chess game has not yet ended");

        games[gameAddress].isOver = true;

        address playerWhite = games[gameAddress].playerWhite;
        address playerBlack = games[gameAddress].playerBlack;
        playerActiveGames[playerWhite]--;
        playerActiveGames[playerBlack]--;
    }

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

        lockedTokens[player][tokenId] += lockAmount;
    }

    function unlockPlayerTokens(
        address player,
        uint256 tokenId,
        uint256 unlockAmount
    ) public {
        require(
            (msg.sender == player) || (msg.sender == owner),
            "Only the token owner or smart contract owner can perform this action"
        );
        require(
            playerActiveGames[player] == 0,
            "Player must conclude all ongoing games before unlocking pieces"
        );

        lockedTokens[player][tokenId] -= unlockAmount;

        IChessCollection chessCollection = IChessCollection(
            chessCollectionAddress
        );
        chessCollection.safeTransferFrom(
            address(this),
            player,
            tokenId,
            unlockAmount,
            ""
        );
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
}
