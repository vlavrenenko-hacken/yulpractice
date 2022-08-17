// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract AngleExplainBase {
    uint private secretNumber;
    mapping(address => uint) public guesses;

    bytes32 public secretWord;

    function getSecretNumber() external view returns(uint) {
        return secretNumber;
    }

    function setSecretNumber(uint number) external {
        secretNumber = number;
    }

    function addGuess(uint _guess) external {
        guesses[msg.sender] = _guess;
    }

    function addMultipleGuesses(address[] memory _users, uint[] memory _guesses) external {
        for (uint i = 0; i < _users.length; i++) {
            guesses[_users[i]] = _guesses[i];
        }
    }

    function hashSecretWord(string memory _str) external {
        secretWord = keccak256(abi.encodePacked(_str));
    }
}