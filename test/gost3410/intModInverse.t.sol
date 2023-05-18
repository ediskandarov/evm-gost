// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost3410/intModInverse.sol";

contract intModInverseTest is Test {
    using uintModInverse for uint;

    function test_bgcd_1() external {
        assertEq(uintModInverse.bgcd(11, 35), 1);
    }

    function test_bgcd_2() external {
        assertEq(
            uintModInverse.bgcd(
                6322610860491544216932366519095,
                177213750118348710766018615863777
            ),
            180646024585472691912353329117
        );
    }

    function test_ext_bgcd() external {
        (int a, int b, int v) = uintModInverse.ext_bgcd(693, 609);
        assertEq(a, -181);
        assertEq(b, 206);
        assertEq(v, 21);
    }

    function test_ext_bgcd_1() external {
        (int a, int b, int v) = uintModInverse.ext_bgcd(609, 693);
        assertEq(a, 173);
        assertEq(b, -152);
        assertEq(v, 21);
    }

    function test_ext_bgcd_v2() external {
        (uint v, uint a, bool isAPos) = uintModInverse.ext_bgcd_v2(693, 609);
        assertEq(a, 181);
        assertFalse(isAPos);
        // assertEq(b, 206);
        // assertTrue(isBPos);
        assertEq(v, 21);
    }

    function test_ext_bgcd_v2_1() external {
        (uint v, uint a, bool isAPos) = uintModInverse.ext_bgcd_v2(609, 693);
        assertEq(a, 173);
        assertTrue(isAPos);
        // assertEq(b, 206);
        // assertTrue(isBPos);
        assertEq(v, 21);
    }

    function test_ext_bgcd_v3_1() external {
        (uint v, uint a, bool isAPos) = uintModInverse.ext_bgcd_v3(609, 693);
        assertEq(a, 173);
        assertTrue(isAPos);
        // assertEq(b, 206);
        // assertTrue(isBPos);
        assertEq(v, 21);
    }

    function test_ext_bgcd_v2_case_1() external {
        uintModInverse.ext_bgcd_v2(
            0xffff030700000000ffffffffffffff030000000000f8ffffffff0300c0ffffff,
            0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141
        );

        // 0xe06f56d8558f81fddbd19d1d68aee4415a7184142d76b9dd8368e243b2fcdaa8
    }

    function test_modinv() external {
        assertEq(uint(23).modinv(97), 38);
        assertEq(uint(23).modinv(99), 56);
        assertEq(uint(11).modinv(35), 16);
        assertEq(uint(38).modinv(93), 71);
    }

    function test_modulo_operation() external {
        assertEq(uintModInverse.modulo_v2(145, true, 51), 43);
        assertEq(uintModInverse.modulo_v2(145, false, 51), 8);
    }
}
