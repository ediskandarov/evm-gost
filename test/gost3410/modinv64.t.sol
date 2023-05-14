// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost3410/modinv64.sol";

contract Modinv64Test is Test {
    function test_ctz() external {
        uint res = modinv64.ctz64(uint64(0x20));

        assertEq(res, 5);
    }

    function test_negate_u64() external {
        assertEq(modinv64.negate_u64(12), 0xfffffffffffffff4);
        assertEq(modinv64.negate_u64(0), 0);
    }
}
