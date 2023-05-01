// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost/uintGostUtils.sol";

contract uintGostUtilsTest is Test {
    using uintGostUtils for uint;

    function test_bswap64() external {
        uint x = 0x1122334455667788;

        uint64 swapped = x.bswap64();

        assertEq(swapped, 0x8877665544332211);
    }
}
