// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IChessPieceCollection {
    
}

contract GameManager {
    struct GamePlayers{
        address playerWhite;
        address playerBlack;
    }

    struct Piece{
        uint256 pieceType;
        bytes32 pieceId;
    }

    mapping (address => GamePlayers) games;
    address public chessPieceCollectionAddress;

    event GameCreated();
    event PlayerSelectedPieces();

    constructor() {}

    function createChessGame(
        address _playerWhite,
        address _playerBlack
    ) public returns (address) {

    }

    function placePieces(
        address player,
        address game,
        Piece[] memory pieces
    ) public {
        IERC1155 chessCollection = IERC1155(chessPieceCollectionAddress);
        
        // Confirm player has all specified pieces
        for(uint i; i < pieces.length; i++){
            Piece piece = pieces[i];
            uint256[] balances = chessCollection.balanceOfBatch(
                [player, address(0)],
                [piece.pieceType, piece.pieceType]
            );
            require(
                balances[0] > 0 || balances[1] > 0,
                "User must have the specified pieceType or it must be a default piece available to everyone"
            );
        }

        // Stake all player's pieces currently in game, so they can not be transferred during a game
    }

    function joinGame(address player){

    }
}
