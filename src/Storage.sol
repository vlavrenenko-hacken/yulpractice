// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Storage {
    uint private a = 100;
    uint private b = 1341;

    function getStorageLocation() external pure returns(uint, uint) {
        uint slotA;
        uint slotB;

        assembly {
            slotA := a.slot
            slotB := b.slot
        }

        return (slotA, slotB);
    }

    function getValueAtSlot(uint slot) external view returns (uint) {
        uint value;

        assembly {
            value := sload(slot)
        }
        
        return value;
    }
}