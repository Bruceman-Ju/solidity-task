// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";

contract MockNFT is ERC721URIStorage {
    
    uint256 public tokenId;

    constructor() ERC721("MockNFT", "MNFT") {}

    function mintNFT(string memory tokenURI) external returns (uint256) {
        
        tokenId++;

        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }
}