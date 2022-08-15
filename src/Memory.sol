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

    function addition(uint x, uint y) external pure returns (uint) {
        assembly {

            // Create a new variable `result`
            //  -> calculate the sum of `x + y` with the `add` opcode
            //  -> assign the value to `result`

            let result := add(x, y) // x + y

            // Use the `mstore` opcode, to:
            // -> store `result` in memory
            // -> at memory address 0x0
            mstore(0x80, result) // store result in memory
            return(0x80, 32) // return 32 bytes from memory
        }
    }

    function multiplication(uint itr, uint value) external pure returns {
        assembly {
            for { let i := 0 } lt(i, n) { i := add(i, 1) } {
                value := mul(2, value)
            }
            mstore(0x80, value)
            return(0x80, 32)
        }
    }
}