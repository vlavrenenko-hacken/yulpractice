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
    }
}