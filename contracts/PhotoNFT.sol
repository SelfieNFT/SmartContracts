// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { compareStrings } from "./utils.sol";


struct PhotoState {
    uint256 numLikes;
    uint256 numDislikes;
    uint256 numFlags;
}

struct Comment {
    address author;
    string ipfsURI;
}


contract PhotoNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // photoId => array of comments stored on ipfs
    mapping(uint256 => string[]) public comments;

    // states of photo
    mapping(uint256 => PhotoState) public photoStates;

    constructor(string memory name, string memory symbol)
    ERC721(name, symbol) {}

    function mintPhoto(string memory ipfsPhotoURI) public {
        uint256 newPhotoId = _tokenIds.current();
        _safeMint(msg.sender, newPhotoId);
        _setTokenURI(newPhotoId, ipfsPhotoURI);
        _tokenIds.increment();
    }

    // burn the NFT token by only allowed users
    function deletePhoto(uint256 photoId) public photoExists(photoId) {
        _burn(photoId);
        comments[photoId] = new string[](0);
        delete photoStates[photoId];
    }

    modifier photoExists(uint256 photoId) {
        require(_exists(photoId), "Token doesn't exist");
        _;
    }

    // add comment to photoId token
    function addComment(uint256 photoId, string memory commentIpfsURI) public photoExists(photoId) {
        comments[photoId].push(commentIpfsURI);
    }

    function commentExists(uint256 photoId, string memory commentIpfsURI) public view photoExists(photoId) returns(bool) {
        for(uint256 i; i < comments[photoId].length; i++)
            if(compareStrings(comments[photoId][i], commentIpfsURI))
                return true;
        return false;
    }

    modifier commentExist(uint256 photoId, string memory commentIpfsURI) {
        require(commentExists(photoId, commentIpfsURI), "Comment doesn't exists");
        _;
    }

    function removeComment(uint256 photoId, string memory commentIpfsURI) public
    commentExist(photoId, commentIpfsURI) {
        string[] storage _comments = comments[photoId];

        // if(_comments.length == 1) {
        //     _comments.pop();
        //     return;
        // }

        uint256 index = _findCommentId(_comments, commentIpfsURI);

        // swap last item from array with index of item to delete
        _comments[index] = _comments[_comments.length - 1];
        _comments.pop();
    }

    function _findCommentId(string[] memory _comments, string memory commentIpfsURI) private pure returns(uint256) {
        for(uint256 i; i < _comments.length; i++)
            if(compareStrings(_comments[i], commentIpfsURI))
                return i;
        revert("Cannot find comment ID");
    }

    function updateComment(uint256 photoId, string memory oldCommentIpfsURI, string memory newCommentIpfsURI) public
    commentExist(photoId, oldCommentIpfsURI) {
        removeComment(photoId, oldCommentIpfsURI);
        addComment(photoId, newCommentIpfsURI);
    }

    function thumbUpOrDown(uint256 photoId, int8 sign) public photoExists(photoId) {
        if(sign == 1)
            photoStates[photoId].numLikes++;
        else if(sign == -1)
            photoStates[photoId].numDislikes++;
        else
            revert("Wrong number passed");

    }

    // function flagPhoto();

    // function flagComment();

}
