// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../src/Storage.sol";

contract StorageTest is Test {
    Storage private _storage;
    function setUp() external {
        _storage = new Storage();
    }

    function testGetStorageLOcation() external {
        (uint slotA, uint slotB) = _storage.getStorageLocation();
        
        assertEq(slotA, 0);
        assertEq(slotB, 1);
    }

    function testGetValueAtSlot() external {
        uint a = _storage.getValueAtSlot(0);
        uint b = _storage.getValueAtSlot(1);

        assertEq(a, 100);
        assertEq(b, 1341);
    }
}