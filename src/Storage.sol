// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Storage {
    uint private a = 100;
    uint private b = 1341;
    uint128 private c = 1;
    uint128 private d = 2;

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

    function getOffset() external pure returns (uint offsetC, uint offsetD) {
        assembly {
            offsetC := c.offset
            offsetD := d.offset
        }
    }
}