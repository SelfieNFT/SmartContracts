// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract Auction {
    struct AuctionMember {
        address memberAddress;
        uint256 balance;
    }

    enum AuctionState {
        UNDEFINED,
        RUNNING,
        RESOLVING,
        ENDED
    }

    struct AuctionInfo {
        uint256 minEntranceFee;
        uint256 endTime;
        uint256 highestBid;
        address currentWinner;
        AuctionState state;
    }

    // NFT id => auction member
    mapping(uint256 => AuctionMember[]) auctionMembers;
    mapping(uint256 => AuctionInfo) auctionInfos;
    // list of open auction for keeper
    uint256[] openAuctionList;

    IERC721 nftContract;


    event AuctionStarted(uint256 tokenId);
    event Bid(address member, uint256 amount);

    constructor(address _nftContract, address keeperAddress) {
        nftContract = IERC721(_nftContract);
    }

    function startAuction(uint256 tokenId, uint256 minEntranceFee, uint256 endTime) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Wrong sender to contract");
        require(auctionInfos[tokenId].state == AuctionState.UNDEFINED, "Cannot start the Action");
        require(endTime > block.timestamp, "Wrong time set");
        auctionInfos[tokenId] = AuctionInfo(
            minEntranceFee,
            endTime,
            0,
            address(0),
            AuctionState.RUNNING
        );
        openAuctionList.push(tokenId);
        emit AuctionStarted(tokenId);
    }

    function isAuctionRunning(uint256 tokenId) public view returns(bool) {
        return auctionInfos[tokenId].state == AuctionState.RUNNING;
    }

    function timeLeft(uint256 tokenId) public view returns(int256) {
        require(isAuctionRunning(tokenId), "Auction is not running");
        return int256(auctionInfos[tokenId].endTime -  block.timestamp);
    }

    function _getAuctionMembersIndex(uint256 tokenId, address _address) private view returns(bool, uint256) {
        for(uint256 i = 0; i < auctionMembers[tokenId].length; i++) {
            if(auctionMembers[tokenId][i].memberAddress == _address) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function bid(uint256 tokenId) public payable {
        require(isAuctionRunning(tokenId), "Auction is not running");

        (bool flag, uint256 index) = _getAuctionMembersIndex(tokenId, msg.sender);
        uint256 balance = 0;

        if(flag) {
            balance = auctionMembers[tokenId][index].balance;
        }
        uint256 newBid = msg.value + balance;
        require(
            newBid >= auctionInfos[tokenId].minEntranceFee
            && newBid > auctionInfos[tokenId].highestBid,
            "Too small to bid"
        );

        if(!flag) {
            auctionMembers[tokenId].push(AuctionMember(msg.sender, msg.value));
        }
        else {
            auctionMembers[tokenId][index].balance += msg.value;
        }

        auctionInfos[tokenId].highestBid = newBid;
        auctionInfos[tokenId].currentWinner = msg.sender;

        emit Bid(msg.sender, newBid);

    }

    function _tearDown(uint256 tokenId) private {
        delete auctionInfos[tokenId];
        // TODO: pop array in loop
        delete auctionMembers[tokenId];

        for(uint256 i = 0; i < openAuctionList.length; i++) {
            if(openAuctionList[i] == tokenId) {
                openAuctionList[i] = openAuctionList[openAuctionList.length - 1];
                openAuctionList.pop();
            }
        }
        revert("Inconsistency in contract storage during tearing down");
    }

    function endAuction(uint256 tokenId) public {
        require(auctionInfos[tokenId].state == AuctionState.ENDED, "Auction not ended yet");
        address payable oldOwnerAddress = payable(nftContract.ownerOf(tokenId));
        // transfer NFT to winner
        for(uint256 i = 0; i < auctionMembers[tokenId].length; i++) {
            if(auctionMembers[tokenId][i].memberAddress == auctionInfos[tokenId].currentWinner) {
                nftContract.safeTransferFrom(
                    oldOwnerAddress,
                    auctionInfos[tokenId].currentWinner,
                    tokenId
                );
                // TODO: make 60% as a variable
                oldOwnerAddress.transfer(auctionMembers[tokenId][i].balance * 60 / 100);
                continue;
            }
            // withdraw money of those who hasn't won
            payable(auctionMembers[tokenId][i].memberAddress).transfer(auctionMembers[tokenId][i].balance);
        }

        _tearDown(tokenId);
    }

}
