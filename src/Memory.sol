// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Memory {
    function getAllocatedMemory(uint[3] memory _arr) external pure returns (uint ptr) {
        assembly {
            ptr := mload(64) // 224 bytes = 128 + 5*32
        }
    }

    function getSelector() external pure returns (bytes4 selector) {
        assembly{
            selector := calldataload(0)
        }
    }

    function getCalldata(string calldata _str) external pure returns(bytes32 data){
        assembly{
            data := calldataload(add(4, 64))
            // 4 -> 0x0000000000000000000000000000000000000000000000000000000000000020 -> (16 numerical system - 20, decimal - 32) 20 bytes left till the start of the string storage
            // 4 + 32 -> 0x0000000000000000000000000000000000000000000000000000000000000004 -> 4 bytes (length of a string in bytes)
            // 4 + 64 -> 0x7465737400000000000000000000000000000000000000000000000000000000 -> 32 bytes (string)
            // 0x7465737400000000000000000000000000000000000000000000000000000000 = "test"
        }
    }
}