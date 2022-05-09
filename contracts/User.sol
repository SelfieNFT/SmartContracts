// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { compareStrings } from "./utils.sol";


contract User {
    // todo: Add some event on user change ?
    mapping(address => string) public userNames;

    function userExists() public view returns(bool) {
        return bytes(userNames[msg.sender]).length > 0;
    }

    function addUser(string memory userName) public {
        require(bytes(userName).length > 0, "Empty user name");
        require(!userExists(), "User already exists");
        userNames[msg.sender] = userName;
    }


    function changeUserName(string memory newUserName) public {
        require(bytes(newUserName).length > 0, "Empty user name");
        require(userExists(), "Add user first");
        require(!compareStrings(userNames[msg.sender], newUserName), "New and old name are the same");
        userNames[msg.sender] = newUserName;
    }

    function deleteUser() public {
        require(userExists(), "User does not exist");
        delete userNames[msg.sender];
    }
}