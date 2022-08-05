// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../src/Memory.sol";
import "forge-std/console.sol";


contract MemoryTest is Test{
    Memory private _memory;
    function setUp() external {
        _memory = new Memory();
    }

    function testGetAllocatedMemory() external {
        uint ptr = _memory.getAllocatedMemory([uint(1), 2, 3]);
        assertEq(ptr, 224);
    }

    // function testGetSelector() external {
    //     bytes4 selector = _memory.getSelector();
    //     assertEq(selector, "0x034899bc");
    // }

    function testGetCalldata() external {
        bytes32 data = _memory.getCalldata("test");
        assertEq(data, 0x7465737400000000000000000000000000000000000000000000000000000000);
    }
}