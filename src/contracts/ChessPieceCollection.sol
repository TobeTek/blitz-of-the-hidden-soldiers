// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

enum ChessPieceClass {
    KING,
    QUEEN,
    PAWN,
    ROOK,
    BISHOP,
    KNIGHT,
    // Exotics
    TREBUCHET
}

struct ChessPieceProperties {
    uint256 tokenId; // Generally the same as the tokenId
    ChessPieceClass pieceClass;
}

interface IChessCollection is IERC1155 {
    function tokenProperties(
        uint256
    ) external view returns (ChessPieceProperties memory);

    function isDefaultPiece(uint256) external view returns (bool);
}

/**
 * @title ChessPieceCollection
 * @dev ERC-1155 token contract representing chess pieces collectibles for the Blitz of the Hidden Soldiers (BoTHS) game
 * @custom:security-contact katchyemma@gmail.com
 */
contract ChessPieceCollection is
    ERC1155,
    Ownable,
    ERC1155Pausable,
    ERC1155Burnable,
    ERC1155Supply
{
    mapping(uint256 => ChessPieceProperties) public tokenProperties;

    address public defaultTokenOwner;

    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {
        defaultTokenOwner = initialOwner;
    }

    ///////////////////////////
    //  Custom Functions
    //////////////////////////
    function setDefaultTokenOwner(address newOwner) public onlyOwner {
        defaultTokenOwner = newOwner;
    }

    function setPieceProperties(
        uint256 tokenId,
        ChessPieceProperties calldata pieceProperty
    ) public onlyOwner {
        tokenProperties[tokenId] = pieceProperty;
    }

    function isDefaultPiece(uint256 tokenId) public view returns (bool) {
        return (balanceOf(defaultTokenOwner, tokenId) > 0);
    }

    ////////////////////////////////
    // ERC1155 - Standard
    ///////////////////////////////
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
