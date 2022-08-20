// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract LotteryYul {
    uint private secretNumber;
    mapping(address => uint) public guesses;
    bytes32 public secretWord;

    function getSecretNumber() external view returns(uint) {
        assembly {
            // We get the value for secretNumber which is at slot 0
            // in Yul, you also have access to the slot number of a variable through `.slot`
						// <https://docs.soliditylang.org/en/latest/assembly.html#access-to-external-variables-functions-and-libraries>
            // so we could also just write `sload(secretNumber.slot)`
            // SLOAD <https://www.evm.codes/#54>
            let _secretNumber := sload(0)
            // then we get the "free memory pointer"
            // that means we get the address in the memory where we can write to
            // we use the MLOAD opcode for that: <https://www.evm.codes/#51>
            // We get the value stored at 0x40 (64)
            // 0x40 is just a constant decided in the EVM where the address of the free memory is stored
            // see here: <https://docs.soliditylang.org/en/latest/assembly.html#memory-management>
            let ptr := mload(0x40)
            // we write our number at that address
            // to do that, we use the MSTORE opcode: <https://www.evm.codes/#52>
            // It takes 2 parameters: the address in memory where to store our value, and the value to store
            mstore(ptr, _secretNumber)
            // then we RETURN the value: <https://www.evm.codes/#f3>
            // we specify the address where the value is stored: `ptr`
            // and the size of the parameter returned: 32 bytes (remember values are always stored on 32 bytes)
            return(ptr, 0x20)
        }

        // First two slots aka. scratch space can be used to store temporary data. We could have used them to store our "secretNumber"
        // assembly {
        //     let _secretNumber := sload(0)
        //     mstore(0, _secretNumber)
        //     return(0, 0x20)
        // }
    }

    function getSecretNumber1() external view returns (uint) {
        assembly {
            let _secretNumber := sload(0)
            mstore(0, _secretNumber)
            return(0, 0x20)
        }
    }

    function setSecretNumber(uint _number) external {
        assembly {
            let slot := secretNumber.slot
            sstore(slot, _number)
        }
    }

    function addGuess(uint _guess) external {
        assembly {
            // first we compute the slot where we will store the value
            let ptr := mload(0x40)

            // we store the address of msg.sender at `ptr` address
            mstore(ptr, caller())
            mstore(add(ptr, 0x20), guesses.slot)

            // compute the hash of the msg.sender and guesses.slot
            let slot := keccak256(ptr, 0x40) // from to

            // we now only need to store the value at that slot
            sstore(slot, _guess)
        }
    }

    function hashSecretWord(string memory _str) external {
        assembly {
            // computes the keccak256 hash of a string and stores it in a state variable
            // _str is a pointer to the string, it represents the address in memory where the data for our string starts
            // at _str we have the length of the string
            // at _str + 32 -> we have the string itself

            // here we got the size of the string
            let strSize := mload(_str)
            
            // here we add 32 to that address, so that we have the address of the string itself
            let strAddr := add(_str, 32)

            // we then pass the address of the string, and its size. This will hash our string
            let hash := keccak256(strAddr, strSize)

            // we store the hash value at slot 0 in memory
            // just like we explained before, this is used as temporary storage (scratch space)
            // no need to get the free memory pointer, it's faster (and cheaper) to use 0
            mstore(0, hash)

            // we return what is stored at slot 0 (our hash) and the length of the hash (32)
            return (0, 32)
        }
    }


    // the same as hashSecretWord1 but using a different technique
    function hashSecretWord1(string calldata) external {
        assembly {
            // the calldata represents the entire data passed to a contract when calling a function
            // the first 4 bytes always represent the signature of the function, and the rest are the parameters
            // here we can skip the signature because we are already in the function, so the signature obviously represent the current function
            // we can use CALLDATALOAD to load 32 bytes from the calldata.
            // we use calldataload(4) to skip the signature bytes. This will therefore load the 1st parameter
            // when using non-value types (array, mapping, bytes, string) the first parameter is going to be the offset where the parameter starts
            // at that offset, we'll find the length of the parameter, and then the value
            // this is the offset in `calldata` where our string starts
            // here we use calldataload(4) -> loads the offset where the string starts
            // -> we add 4 to that offset to take into account the signature bytes
            // <https://www.evm.codes/#35>
            let strOffset := add(4, calldataload(4))
            // we use calldataload() again with the offset we just computed, this gives us the length of the string (the value stored at the offset)
            let strSize := calldataload(strOffset)

            // we load the free memory pointer
            let ptr := mload(0x40)

            // we copy the value of our string into that free memory
            // CALLDATACOPY <https://www.evm.codes/#37>
            // the string starts at the next memory slot, so we add 0x20 to it

            calldatacopy(ptr, add(strOffset, 0x20), strSize)

            // then we compute the hash of that string
            // remember, the string is now stored at `ptr`
            
            let hash := keccak256(ptr, strSize)

            // and we store it to storage
            sstore(secretWord.slot, hash)
        }
    }    

    function addMultipleGuesses(address[] memory _users, uint[] memory _guesses) external {
        assembly {
            let usersSize := mload(_users) // the length of the array `_users`
            let guessesSize := mload(_guesses) // the length of the array `_guesses`

            if iszero(eq(usersSize, guessesSize)) {
                revert(0, 0)
            }

            for { let i := 0 } lt(i, usersSize) { i := add(i,1)} {
                let userAddress := mload(add(_users, mul(0x20, add(i, 1))))
                let userBalance := mload(add(_guesses, mul(0x20, add(i, 1))))
                
                // we use the 0 memory slot as temporary storage to compute our hash
                // we store the address there
                mstore(0, userAddress)
                // then the slot number for `guesses`
                mstore(0x20, guesses.slot)
                // we compute the storage slot number
                let slot := keccak256(0, 0x40)
                // and store our value to it
                sstore(slot, userBalance)
            }
        }
    }

}