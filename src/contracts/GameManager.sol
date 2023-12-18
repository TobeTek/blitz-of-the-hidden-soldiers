// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./ChessGame.sol";
import "./ChessPieceCollection.sol";

import {ChessPieceProperties} from "./ChessPieceCollection.sol";

enum PieceClass {
    KING,
    QUEEN,
    BISHOP,
    KNIGHT,
    ROOK,
    PAWN
}

struct PieceSelection {
    PieceClass pieceClass;
    uint256 tokenId;
    uint256 count;
}

interface IChessCollection is IERC1155 {
    function tokenProperties(
        uint256
    ) external view returns (ChessPieceProperties);
}

// Manage creating games between players
// Lock pieces currently in game
contract GameManager {
    struct GameData {
        address playerWhite;
        address playerBlack;
        bool isOver;
    }

    // struct Piece {
    //     uint256 pieceType;
    //     bytes32 pieceId;
    // }

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

    // Address of the BoTHS NFT Collection Smart Contract
    address public chessCollectionAddress;

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
        ChessGame game = new ChessGame(playerWhite, playerBlack);
        games[game] = GameData(playerWhite, playerBlack);

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

    // Verify that the right pieces were used in the right proportion
    function validatePieceFormation(PieceSelection[] memory pieces) public {
        // Standard Chess Formation
        mapping(PieceClass => uint) standardChessFormation;
        standardChessFormation[PieceClass.KING] = 1;
        standardChessFormation[PieceClass.QUEEN] = 1;
        standardChessFormation[PieceClass.BISHOP] = 2;
        standardChessFormation[PieceClass.KNIGHT] = 2;
        standardChessFormation[PieceClass.ROOK] = 2;
        standardChessFormation[PieceClass.PAWN] = 8;
        bool isStandardFormation = true;

        // All Pawns Formation
        mapping(PieceClass => uint) allPawnsFormation;
        allPawnsFormation[PieceClass.KING] = 1;
        allPawnsFormation[PieceClass.QUEEN] = 1;
        allPawnsFormation[PieceClass.BISHOP] = 0;
        allPawnsFormation[PieceClass.KNIGHT] = 0;
        allPawnsFormation[PieceClass.ROOK] = 0;
        allPawnsFormation[PieceClass.PAWN] = 16;
        bool isAllPawmFormation = true;

        mapping(PieceClass => uint256) classTally;
        PieceClass[] memory allClasses;

        for (uint i = 0; i < pieces.length; i++) {
            PieceSelection memory piece = pieces[i];
            IChessCollection chessCollection = IChessCollection(
                chessCollectionAddress
            );

            ChessPieceProperties pieceProperties = chessCollection
                .tokenProperties(piece.tokenId);

            require(
                piece.pieceClass == pieceProperties.pieceClass,
                "Input pieceClass and actual pieceClass do not match."
            );

            if (classTally[pieceProperties.pieceClass] == 0) {
                allClasses.push(pieceProperties.pieceClass);
            }
            classTally[pieceProperties.pieceClass] += piece.count;
        }

        for (uint i = 0; i < allClasses.length; i++) {
            PieceClass pieceClass = allClasses[i];
            isStandardFormation =
                isStandardFormation &&
                (standardChessFormation[pieceClass] == classTally[PieceClass]);
            isAllPawmFormation =
                isAllPawmFormation &&
                (allPawnsFormation[pieceClass] == classTally[PieceClass]);
        }

        // TODO: Support more formations
        require(
            isStandardFormation || isAllPawmFormation,
            "This piece formation is not allowed."
        );
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
            PieceSelection calldata piece = pieces[i];
            address[] memory accounts;
            accounts[0] = player;
            accounts[1] = address(0);

            uint256[] memory pieceIds;
            pieceIds[0] = piece.pieceType;
            pieceIds[1] = piece.pieceType;

            uint256[] memory balances = chessCollection.balanceOfBatch(
                accounts,
                pieceIds
            );

            // We only check if either the player as an entity has that number of pieces.
            // We can also check if a combination of both the player's balance and the default pieceset
            // can meet the desired number, however, generally, we want to prevent such 'mixing' of ownership
            uint256 lockedPlayerTokens = lockedTokens[player][piece.pieceType];
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
            if (playerHasPieces && lockAmount) {
                lockPlayerTokens(player, piece.tokenId, lockAmount);
            }
        }
    }

    function markGameAsOver(address gameAddress) public {
        ChessGame game = ChessGame(gameAddress);
        require(game.isGameOver, "This chess game has not yet ended");

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
            lockAmount
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
            !playerActiveGames[player],
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
            unlockAmount
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
