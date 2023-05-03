// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost3410/intModInverse.sol";

contract intModInverseTest is Test {
    using uintModInverse for uint;

    function test_egcd_1() external {
        (uint g, uint x, uint y) = uintModInverse.egcd(23, 97);
        assertEq(g, 1);
        assertEq(x, 38);
        // assertEq(y, -9);
    }

    function test_egcd_2() external {
        (uint g, uint x, uint y) = uintModInverse.egcd(23, 99);
        assertEq(g, 1);
        // assertEq(x, -43);
        assertEq(y, 10);
    }

    function test_egcd_3() external {
        (uint g, uint x, uint y) = uintModInverse.egcd(11, 35);
        assertEq(g, 1);
        assertEq(x, 16);
        // assertEq(y, -5);
    }

    function test_modinv() external {
        assertEq(uint(23).modinv(97), 38);
        assertEq(uint(23).modinv(99), 56);
        assertEq(uint(11).modinv(35), 16);
        assertEq(uint(38).modinv(93), 71);
    }
}
