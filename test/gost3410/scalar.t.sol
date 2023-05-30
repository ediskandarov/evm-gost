// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost3410/scalar.sol";

contract ScalarTest is Test {
    function test_scalar_set_b32() external {
        // prettier-ignore
        uint8[32] memory b32 = [0xff, 0xff, 0x03, 0x07, 0x00, 0x00, 0x00, 0x00,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x03,
            0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xff, 0xff,
            0xff, 0xff, 0x03, 0x00, 0xc0, 0xff, 0xff, 0xff];
        (uint x, ) = scalar.scalar_set_b32(b32);

        assertEq(
            bytes32(x),
            hex"ffff030700000000ffffffffffffff030000000000f8ffffffff0300c0ffffff"
        );
    }

    function test_scalar_mul() external {
        uint256 a = 0xffffffffffffffff8899aabbccddeeff11223344556677889900aabbccddeeff;
        uint256 b = 0xfffe060ef9fb2a32fffe060dfffffe0701f4042a01f1fc19e39c060377f5a697;

        uint256 r = scalar.scalar_mul(a, b);

        // Result calculated in python (a * b) % SECP256K1_N
        assertEqUint(
            r,
            0x5267cf099f11c32ab5773096c8b2d07c96e4a62c4287583415e2b0367a93a832
        );
    }

    function test_scalar_check_overflow() external {
        assertFalse(scalar.scalar_check_overflow(1));
        assertTrue(scalar.scalar_check_overflow(type(uint256).max));
    }

    function test_u128_from_u64() external {
        bytes32 xHex = (
            hex"00112233445566778899aabbccddeeff"
            hex"11223344556677889900aabbccddeeff"
        );
        uint256 x = uint256(xHex);
        assertEq(scalar.u128_from_u64(x, 0), 0x9900aabbccddeeff);
        assertEq(scalar.u128_from_u64(x, 1), 0x1122334455667788);
        assertEq(scalar.u128_from_u64(x, 2), 0x8899aabbccddeeff);
        assertEq(scalar.u128_from_u64(x, 3), 0x0011223344556677);
    }

    function test_scalar_set_u64() external {
        bytes32 xHex = (
            hex"00112233445566778899aabbccddeeff"
            hex"11223344556677889900aabbccddeeff"
        );
        uint256 x = uint256(xHex);

        uint256 result = scalar.scalar_set_u64(x, 0xffffffffffffffff, 0);
        assertEq(
            result,
            0x00112233445566778899aabbccddeeff1122334455667788ffffffffffffffff
        );

        result = scalar.scalar_set_u64(x, 0xffffffffffffffff, 1);
        assertEq(
            result,
            0x00112233445566778899aabbccddeeffffffffffffffffff9900aabbccddeeff
        );

        result = scalar.scalar_set_u64(x, 0xffffffffffffffff, 2);
        assertEq(
            result,
            0x0011223344556677ffffffffffffffff11223344556677889900aabbccddeeff
        );

        result = scalar.scalar_set_u64(x, 0xffffffffffffffff, 3);
        assertEq(
            result,
            0xffffffffffffffff8899aabbccddeeff11223344556677889900aabbccddeeff
        );
    }

    function test_scalar_reduce() external {
        uint256 x = 0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_ffffffff_AF48A03B_BFD25E8C_D0364141;

        (uint res, ) = scalar.scalar_reduce(x, 1);
        assertEq(res, 0x45512319000000000000000000000000); // scalar reduce does this: x % N
    }

    /**
     * backport of `run_scalar_tests` test
     * https://github.com/bitcoin-core/secp256k1/blob/master/src/tests.c#L2343
     */
    function test_scalar() external {
        // prettier-ignore
        uint8[32][2][33]  memory chal = [
            [[0xff, 0xff, 0x03, 0x07, 0x00, 0x00, 0x00, 0x00,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x03,
              0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xff, 0xff,
              0xff, 0xff, 0x03, 0x00, 0xc0, 0xff, 0xff, 0xff],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0x0f, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xff]],
            [[0xef, 0xff, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00,
              0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0x3f, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
             [0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe0,
              0xff, 0xff, 0xff, 0xff, 0xfc, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0x7f, 0x00, 0x80, 0xff]],
            [[0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00,
              0x80, 0x00, 0x00, 0x80, 0xff, 0x3f, 0x00, 0x00,
              0x00, 0x00, 0x00, 0xf8, 0xff, 0xff, 0xff, 0x00],
             [0x00, 0x00, 0xfc, 0xff, 0xff, 0xff, 0xff, 0x80,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x0f, 0x00, 0xe0,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x7f, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x7f, 0xff, 0xff, 0xff]],
            [[0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x00, 0x1e, 0xf8, 0xff, 0xff, 0xff, 0xfd, 0xff],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x1f,
              0x00, 0x00, 0x00, 0xf8, 0xff, 0x03, 0x00, 0xe0,
              0xff, 0x0f, 0x00, 0x00, 0x00, 0x00, 0xf0, 0xff,
              0xf3, 0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00]],
            [[0x80, 0x00, 0x00, 0x80, 0xff, 0xff, 0xff, 0x00,
              0x00, 0x1c, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xe0, 0xff, 0xff, 0xff, 0x00,
              0x00, 0x00, 0x00, 0x00, 0xe0, 0xff, 0xff, 0xff],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x03, 0x00,
              0xf8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0x1f, 0x00, 0x00, 0x80, 0xff, 0xff, 0x3f,
              0x00, 0xfe, 0xff, 0xff, 0xff, 0xdf, 0xff, 0xff]],
            [[0xff, 0xff, 0xff, 0xff, 0x00, 0x0f, 0xfc, 0x9f,
              0xff, 0xff, 0xff, 0x00, 0x80, 0x00, 0x00, 0x80,
              0xff, 0x0f, 0xfc, 0xff, 0x7f, 0x00, 0x00, 0x00,
              0x00, 0xf8, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00],
             [0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80,
              0x00, 0x00, 0xf8, 0xff, 0x0f, 0xc0, 0xff, 0xff,
              0xff, 0x1f, 0x00, 0x00, 0x00, 0xc0, 0xff, 0xff,
              0xff, 0xff, 0xff, 0x07, 0x80, 0xff, 0xff, 0xff]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0x3f, 0x00, 0x00,
              0x80, 0x00, 0x00, 0x80, 0xff, 0xff, 0xff, 0xff,
              0xf7, 0xff, 0xff, 0xef, 0xff, 0xff, 0xff, 0x00,
              0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0xf0],
             [0x00, 0x00, 0x00, 0x00, 0xf8, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0x01, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x80, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]],
            [[0x00, 0xf8, 0xff, 0x03, 0xff, 0xff, 0xff, 0x00,
              0x00, 0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x80, 0x00, 0x00, 0x80, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0x03, 0xc0, 0xff, 0x0f, 0xfc, 0xff],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xe0, 0xff, 0xff,
              0xff, 0x01, 0x00, 0x00, 0x00, 0x3f, 0x00, 0xc0,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]],
            [[0x8f, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0xf8, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0x7f, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]],
            [[0x00, 0x00, 0x00, 0xc0, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0x03, 0x00, 0x80, 0x00, 0x00, 0x80,
              0xff, 0xff, 0xff, 0x00, 0x00, 0x80, 0xff, 0x7f],
             [0xff, 0xcf, 0xff, 0xff, 0x01, 0x00, 0x00, 0x00,
              0x00, 0xc0, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff,
              0xbf, 0xff, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x80, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00]],
            [[0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xff, 0xff,
              0xff, 0xff, 0x00, 0xfc, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0x00, 0x80, 0x00, 0x00, 0x80,
              0xff, 0x01, 0xfc, 0xff, 0x01, 0x00, 0xfe, 0xff],
             [0xff, 0xff, 0xff, 0x03, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x03, 0x00]],
            [[0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00,
              0xe0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0x00, 0xf8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0x7f, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0xf8, 0xff, 0x01, 0x00, 0xf0, 0xff, 0xff,
              0xe0, 0xff, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xff, 0x00],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00,
              0xfc, 0xff, 0xff, 0x3f, 0xf0, 0xff, 0xff, 0x3f,
              0x00, 0x00, 0xf8, 0x07, 0x00, 0x00, 0x00, 0xff,
              0xff, 0xff, 0xff, 0xff, 0x0f, 0x7e, 0x00, 0x00]],
            [[0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0x1f, 0x00, 0x00, 0xfe, 0x07, 0x00],
             [0x00, 0x00, 0x00, 0xf0, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xfb, 0xff, 0x07, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60]],
            [[0xff, 0x01, 0x00, 0xff, 0xff, 0xff, 0x0f, 0x00,
              0x80, 0x7f, 0xfe, 0xff, 0xff, 0xff, 0xff, 0x03,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x80, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
             [0xff, 0xff, 0x1f, 0x00, 0xf0, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0x3f, 0x00, 0x00, 0x00, 0x00]],
            [[0x80, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf1, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x03,
              0x00, 0x00, 0x00, 0xe0, 0xff, 0xff, 0xff, 0xff]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x7e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0xc0, 0xff, 0xff, 0xcf, 0xff, 0x1f, 0x00, 0x00,
              0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x3f, 0x00, 0x7e,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]],
            [[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0xfc, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7c, 0x00],
             [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80,
              0xff, 0xff, 0x7f, 0x00, 0x80, 0x00, 0x00, 0x00,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x00, 0x00, 0xe0, 0xff, 0xff, 0xff, 0xff, 0xff]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0x1f, 0x00, 0x80,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00],
             [0xf0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0x3f, 0x00, 0x00, 0x80,
              0xff, 0x01, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff,
              0xff, 0x7f, 0xf8, 0xff, 0xff, 0x1f, 0x00, 0xfe]],
            [[0xff, 0xff, 0xff, 0x3f, 0xf8, 0xff, 0xff, 0xff,
              0xff, 0x03, 0xfe, 0x01, 0x00, 0x00, 0x00, 0x00,
              0xf0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x07],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80,
              0xff, 0xff, 0xff, 0xff, 0x01, 0x80, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00]],
            [[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe,
              0xba, 0xae, 0xdc, 0xe6, 0xaf, 0x48, 0xa0, 0x3b,
              0xbf, 0xd2, 0x5e, 0x8c, 0xd0, 0x36, 0x41, 0x40]],
            [[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]],
            [[0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
             [0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xc0,
              0xff, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0xf0, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x00,
              0xf0, 0xff, 0xff, 0xff, 0xff, 0x07, 0x00, 0x00,
              0x00, 0x00, 0x00, 0xfe, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0x01, 0xff, 0xff, 0xff]],
            [[0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe,
              0xba, 0xae, 0xdc, 0xe6, 0xaf, 0x48, 0xa0, 0x3b,
              0xbf, 0xd2, 0x5e, 0x8c, 0xd0, 0x36, 0x41, 0x40],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0x7e, 0x00, 0x00, 0xc0, 0xff, 0xff, 0x07, 0x00,
              0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00,
              0xfc, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
             [0xff, 0x01, 0x00, 0x00, 0x00, 0xe0, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x1f, 0x00, 0x80,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x03, 0x00, 0x00,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]],
            [[0xff, 0xff, 0xf0, 0xff, 0xff, 0xff, 0xff, 0x00,
              0xf0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x00, 0xe0, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01,
              0x80, 0x00, 0x00, 0x80, 0xff, 0xff, 0xff, 0xff],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xff, 0xff,
              0xff, 0xff, 0x3f, 0x00, 0xf8, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0x3f, 0x00, 0x00, 0xc0, 0xf1, 0x7f, 0x00]],
            [[0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0xc0, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x80, 0x00, 0x00, 0x80, 0xff, 0xff, 0xff, 0x00],
             [0x00, 0xf8, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xff,
              0xff, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x80, 0x1f,
              0x00, 0x00, 0xfc, 0xff, 0xff, 0x01, 0xff, 0xff]],
            [[0x00, 0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x80, 0x00, 0x00, 0x80, 0xff, 0x03, 0xe0, 0x01,
              0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0xfc, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00],
             [0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00,
              0xfe, 0xff, 0xff, 0xf0, 0x07, 0x00, 0x3c, 0x80,
              0xff, 0xff, 0xff, 0xff, 0xfc, 0xff, 0xff, 0xff,
              0xff, 0xff, 0x07, 0xe0, 0xff, 0x00, 0x00, 0x00]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
              0xfc, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x07, 0xf8,
              0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80],
             [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x0c, 0x80, 0x00,
              0x00, 0x00, 0x00, 0xc0, 0x7f, 0xfe, 0xff, 0x1f,
              0x00, 0xfe, 0xff, 0x03, 0x00, 0x00, 0xfe, 0xff]],
            [[0xff, 0xff, 0x81, 0xff, 0xff, 0xff, 0xff, 0x00,
              0x80, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x83,
              0xff, 0xff, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80,
              0xff, 0xff, 0x7f, 0x00, 0x00, 0x00, 0x00, 0xf0],
             [0xff, 0x01, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x1f, 0x00, 0x00,
              0xf8, 0x07, 0x00, 0x80, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xc7, 0xff, 0xff, 0xe0, 0xff, 0xff, 0xff]],
            [[0x82, 0xc9, 0xfa, 0xb0, 0x68, 0x04, 0xa0, 0x00,
              0x82, 0xc9, 0xfa, 0xb0, 0x68, 0x04, 0xa0, 0x00,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x6f, 0x03, 0xfb,
              0xfa, 0x8a, 0x7d, 0xdf, 0x13, 0x86, 0xe2, 0x03],
             [0x82, 0xc9, 0xfa, 0xb0, 0x68, 0x04, 0xa0, 0x00,
              0x82, 0xc9, 0xfa, 0xb0, 0x68, 0x04, 0xa0, 0x00,
              0xff, 0xff, 0xff, 0xff, 0xff, 0x6f, 0x03, 0xfb,
              0xfa, 0x8a, 0x7d, 0xdf, 0x13, 0x86, 0xe2, 0x03]]
        ];
        // prettier-ignore
        uint8[32][2][33] memory res = [
            [[0x0c, 0x3b, 0x0a, 0xca, 0x8d, 0x1a, 0x2f, 0xb9,
              0x8a, 0x7b, 0x53, 0x5a, 0x1f, 0xc5, 0x22, 0xa1,
              0x07, 0x2a, 0x48, 0xea, 0x02, 0xeb, 0xb3, 0xd6,
              0x20, 0x1e, 0x86, 0xd0, 0x95, 0xf6, 0x92, 0x35],
             [0xdc, 0x90, 0x7a, 0x07, 0x2e, 0x1e, 0x44, 0x6d,
              0xf8, 0x15, 0x24, 0x5b, 0x5a, 0x96, 0x37, 0x9c,
              0x37, 0x7b, 0x0d, 0xac, 0x1b, 0x65, 0x58, 0x49,
              0x43, 0xb7, 0x31, 0xbb, 0xa7, 0xf4, 0x97, 0x15]],
            [[0xf1, 0xf7, 0x3a, 0x50, 0xe6, 0x10, 0xba, 0x22,
              0x43, 0x4d, 0x1f, 0x1f, 0x7c, 0x27, 0xca, 0x9c,
              0xb8, 0xb6, 0xa0, 0xfc, 0xd8, 0xc0, 0x05, 0x2f,
              0xf7, 0x08, 0xe1, 0x76, 0xdd, 0xd0, 0x80, 0xc8],
             [0xe3, 0x80, 0x80, 0xb8, 0xdb, 0xe3, 0xa9, 0x77,
              0x00, 0xb0, 0xf5, 0x2e, 0x27, 0xe2, 0x68, 0xc4,
              0x88, 0xe8, 0x04, 0xc1, 0x12, 0xbf, 0x78, 0x59,
              0xe6, 0xa9, 0x7c, 0xe1, 0x81, 0xdd, 0xb9, 0xd5]],
            [[0x96, 0xe2, 0xee, 0x01, 0xa6, 0x80, 0x31, 0xef,
              0x5c, 0xd0, 0x19, 0xb4, 0x7d, 0x5f, 0x79, 0xab,
              0xa1, 0x97, 0xd3, 0x7e, 0x33, 0xbb, 0x86, 0x55,
              0x60, 0x20, 0x10, 0x0d, 0x94, 0x2d, 0x11, 0x7c],
             [0xcc, 0xab, 0xe0, 0xe8, 0x98, 0x65, 0x12, 0x96,
              0x38, 0x5a, 0x1a, 0xf2, 0x85, 0x23, 0x59, 0x5f,
              0xf9, 0xf3, 0xc2, 0x81, 0x70, 0x92, 0x65, 0x12,
              0x9c, 0x65, 0x1e, 0x96, 0x00, 0xef, 0xe7, 0x63]],
            [[0xac, 0x1e, 0x62, 0xc2, 0x59, 0xfc, 0x4e, 0x5c,
              0x83, 0xb0, 0xd0, 0x6f, 0xce, 0x19, 0xf6, 0xbf,
              0xa4, 0xb0, 0xe0, 0x53, 0x66, 0x1f, 0xbf, 0xc9,
              0x33, 0x47, 0x37, 0xa9, 0x3d, 0x5d, 0xb0, 0x48],
             [0x86, 0xb9, 0x2a, 0x7f, 0x8e, 0xa8, 0x60, 0x42,
              0x26, 0x6d, 0x6e, 0x1c, 0xa2, 0xec, 0xe0, 0xe5,
              0x3e, 0x0a, 0x33, 0xbb, 0x61, 0x4c, 0x9f, 0x3c,
              0xd1, 0xdf, 0x49, 0x33, 0xcd, 0x72, 0x78, 0x18]],
            [[0xf7, 0xd3, 0xcd, 0x49, 0x5c, 0x13, 0x22, 0xfb,
              0x2e, 0xb2, 0x2f, 0x27, 0xf5, 0x8a, 0x5d, 0x74,
              0xc1, 0x58, 0xc5, 0xc2, 0x2d, 0x9f, 0x52, 0xc6,
              0x63, 0x9f, 0xba, 0x05, 0x76, 0x45, 0x7a, 0x63],
             [0x8a, 0xfa, 0x55, 0x4d, 0xdd, 0xa3, 0xb2, 0xc3,
              0x44, 0xfd, 0xec, 0x72, 0xde, 0xef, 0xc0, 0x99,
              0xf5, 0x9f, 0xe2, 0x52, 0xb4, 0x05, 0x32, 0x58,
              0x57, 0xc1, 0x8f, 0xea, 0xc3, 0x24, 0x5b, 0x94]],
            [[0x05, 0x83, 0xee, 0xdd, 0x64, 0xf0, 0x14, 0x3b,
              0xa0, 0x14, 0x4a, 0x3a, 0x41, 0x82, 0x7c, 0xa7,
              0x2c, 0xaa, 0xb1, 0x76, 0xbb, 0x59, 0x64, 0x5f,
              0x52, 0xad, 0x25, 0x29, 0x9d, 0x8f, 0x0b, 0xb0],
             [0x7e, 0xe3, 0x7c, 0xca, 0xcd, 0x4f, 0xb0, 0x6d,
              0x7a, 0xb2, 0x3e, 0xa0, 0x08, 0xb9, 0xa8, 0x2d,
              0xc2, 0xf4, 0x99, 0x66, 0xcc, 0xac, 0xd8, 0xb9,
              0x72, 0x2a, 0x4a, 0x3e, 0x0f, 0x7b, 0xbf, 0xf4]],
            [[0x8c, 0x9c, 0x78, 0x2b, 0x39, 0x61, 0x7e, 0xf7,
              0x65, 0x37, 0x66, 0x09, 0x38, 0xb9, 0x6f, 0x70,
              0x78, 0x87, 0xff, 0xcf, 0x93, 0xca, 0x85, 0x06,
              0x44, 0x84, 0xa7, 0xfe, 0xd3, 0xa4, 0xe3, 0x7e],
             [0xa2, 0x56, 0x49, 0x23, 0x54, 0xa5, 0x50, 0xe9,
              0x5f, 0xf0, 0x4d, 0xe7, 0xdc, 0x38, 0x32, 0x79,
              0x4f, 0x1c, 0xb7, 0xe4, 0xbb, 0xf8, 0xbb, 0x2e,
              0x40, 0x41, 0x4b, 0xcc, 0xe3, 0x1e, 0x16, 0x36]],
            [[0x0c, 0x1e, 0xd7, 0x09, 0x25, 0x40, 0x97, 0xcb,
              0x5c, 0x46, 0xa8, 0xda, 0xef, 0x25, 0xd5, 0xe5,
              0x92, 0x4d, 0xcf, 0xa3, 0xc4, 0x5d, 0x35, 0x4a,
              0xe4, 0x61, 0x92, 0xf3, 0xbf, 0x0e, 0xcd, 0xbe],
             [0xe4, 0xaf, 0x0a, 0xb3, 0x30, 0x8b, 0x9b, 0x48,
              0x49, 0x43, 0xc7, 0x64, 0x60, 0x4a, 0x2b, 0x9e,
              0x95, 0x5f, 0x56, 0xe8, 0x35, 0xdc, 0xeb, 0xdc,
              0xc7, 0xc4, 0xfe, 0x30, 0x40, 0xc7, 0xbf, 0xa4]],
            [[0xd4, 0xa0, 0xf5, 0x81, 0x49, 0x6b, 0xb6, 0x8b,
              0x0a, 0x69, 0xf9, 0xfe, 0xa8, 0x32, 0xe5, 0xe0,
              0xa5, 0xcd, 0x02, 0x53, 0xf9, 0x2c, 0xe3, 0x53,
              0x83, 0x36, 0xc6, 0x02, 0xb5, 0xeb, 0x64, 0xb8],
             [0x1d, 0x42, 0xb9, 0xf9, 0xe9, 0xe3, 0x93, 0x2c,
              0x4c, 0xee, 0x6c, 0x5a, 0x47, 0x9e, 0x62, 0x01,
              0x6b, 0x04, 0xfe, 0xa4, 0x30, 0x2b, 0x0d, 0x4f,
              0x71, 0x10, 0xd3, 0x55, 0xca, 0xf3, 0x5e, 0x80]],
            [[0x77, 0x05, 0xf6, 0x0c, 0x15, 0x9b, 0x45, 0xe7,
              0xb9, 0x11, 0xb8, 0xf5, 0xd6, 0xda, 0x73, 0x0c,
              0xda, 0x92, 0xea, 0xd0, 0x9d, 0xd0, 0x18, 0x92,
              0xce, 0x9a, 0xaa, 0xee, 0x0f, 0xef, 0xde, 0x30],
             [0xf1, 0xf1, 0xd6, 0x9b, 0x51, 0xd7, 0x77, 0x62,
              0x52, 0x10, 0xb8, 0x7a, 0x84, 0x9d, 0x15, 0x4e,
              0x07, 0xdc, 0x1e, 0x75, 0x0d, 0x0c, 0x3b, 0xdb,
              0x74, 0x58, 0x62, 0x02, 0x90, 0x54, 0x8b, 0x43]],
            [[0xa6, 0xfe, 0x0b, 0x87, 0x80, 0x43, 0x67, 0x25,
              0x57, 0x5d, 0xec, 0x40, 0x50, 0x08, 0xd5, 0x5d,
              0x43, 0xd7, 0xe0, 0xaa, 0xe0, 0x13, 0xb6, 0xb0,
              0xc0, 0xd4, 0xe5, 0x0d, 0x45, 0x83, 0xd6, 0x13],
             [0x40, 0x45, 0x0a, 0x92, 0x31, 0xea, 0x8c, 0x60,
              0x8c, 0x1f, 0xd8, 0x76, 0x45, 0xb9, 0x29, 0x00,
              0x26, 0x32, 0xd8, 0xa6, 0x96, 0x88, 0xe2, 0xc4,
              0x8b, 0xdb, 0x7f, 0x17, 0x87, 0xcc, 0xc8, 0xf2]],
            [[0xc2, 0x56, 0xe2, 0xb6, 0x1a, 0x81, 0xe7, 0x31,
              0x63, 0x2e, 0xbb, 0x0d, 0x2f, 0x81, 0x67, 0xd4,
              0x22, 0xe2, 0x38, 0x02, 0x25, 0x97, 0xc7, 0x88,
              0x6e, 0xdf, 0xbe, 0x2a, 0xa5, 0x73, 0x63, 0xaa],
             [0x50, 0x45, 0xe2, 0xc3, 0xbd, 0x89, 0xfc, 0x57,
              0xbd, 0x3c, 0xa3, 0x98, 0x7e, 0x7f, 0x36, 0x38,
              0x92, 0x39, 0x1f, 0x0f, 0x81, 0x1a, 0x06, 0x51,
              0x1f, 0x8d, 0x6a, 0xff, 0x47, 0x16, 0x06, 0x9c]],
            [[0x33, 0x95, 0xa2, 0x6f, 0x27, 0x5f, 0x9c, 0x9c,
              0x64, 0x45, 0xcb, 0xd1, 0x3c, 0xee, 0x5e, 0x5f,
              0x48, 0xa6, 0xaf, 0xe3, 0x79, 0xcf, 0xb1, 0xe2,
              0xbf, 0x55, 0x0e, 0xa2, 0x3b, 0x62, 0xf0, 0xe4],
             [0x14, 0xe8, 0x06, 0xe3, 0xbe, 0x7e, 0x67, 0x01,
              0xc5, 0x21, 0x67, 0xd8, 0x54, 0xb5, 0x7f, 0xa4,
              0xf9, 0x75, 0x70, 0x1c, 0xfd, 0x79, 0xdb, 0x86,
              0xad, 0x37, 0x85, 0x83, 0x56, 0x4e, 0xf0, 0xbf]],
            [[0xbc, 0xa6, 0xe0, 0x56, 0x4e, 0xef, 0xfa, 0xf5,
              0x1d, 0x5d, 0x3f, 0x2a, 0x5b, 0x19, 0xab, 0x51,
              0xc5, 0x8b, 0xdd, 0x98, 0x28, 0x35, 0x2f, 0xc3,
              0x81, 0x4f, 0x5c, 0xe5, 0x70, 0xb9, 0xeb, 0x62],
             [0xc4, 0x6d, 0x26, 0xb0, 0x17, 0x6b, 0xfe, 0x6c,
              0x12, 0xf8, 0xe7, 0xc1, 0xf5, 0x2f, 0xfa, 0x91,
              0x13, 0x27, 0xbd, 0x73, 0xcc, 0x33, 0x31, 0x1c,
              0x39, 0xe3, 0x27, 0x6a, 0x95, 0xcf, 0xc5, 0xfb]],
            [[0x30, 0xb2, 0x99, 0x84, 0xf0, 0x18, 0x2a, 0x6e,
              0x1e, 0x27, 0xed, 0xa2, 0x29, 0x99, 0x41, 0x56,
              0xe8, 0xd4, 0x0d, 0xef, 0x99, 0x9c, 0xf3, 0x58,
              0x29, 0x55, 0x1a, 0xc0, 0x68, 0xd6, 0x74, 0xa4],
             [0x07, 0x9c, 0xe7, 0xec, 0xf5, 0x36, 0x73, 0x41,
              0xa3, 0x1c, 0xe5, 0x93, 0x97, 0x6a, 0xfd, 0xf7,
              0x53, 0x18, 0xab, 0xaf, 0xeb, 0x85, 0xbd, 0x92,
              0x90, 0xab, 0x3c, 0xbf, 0x30, 0x82, 0xad, 0xf6]],
            [[0xc6, 0x87, 0x8a, 0x2a, 0xea, 0xc0, 0xa9, 0xec,
              0x6d, 0xd3, 0xdc, 0x32, 0x23, 0xce, 0x62, 0x19,
              0xa4, 0x7e, 0xa8, 0xdd, 0x1c, 0x33, 0xae, 0xd3,
              0x4f, 0x62, 0x9f, 0x52, 0xe7, 0x65, 0x46, 0xf4],
             [0x97, 0x51, 0x27, 0x67, 0x2d, 0xa2, 0x82, 0x87,
              0x98, 0xd3, 0xb6, 0x14, 0x7f, 0x51, 0xd3, 0x9a,
              0x0b, 0xd0, 0x76, 0x81, 0xb2, 0x4f, 0x58, 0x92,
              0xa4, 0x86, 0xa1, 0xa7, 0x09, 0x1d, 0xef, 0x9b]],
            [[0xb3, 0x0f, 0x2b, 0x69, 0x0d, 0x06, 0x90, 0x64,
              0xbd, 0x43, 0x4c, 0x10, 0xe8, 0x98, 0x1c, 0xa3,
              0xe1, 0x68, 0xe9, 0x79, 0x6c, 0x29, 0x51, 0x3f,
              0x41, 0xdc, 0xdf, 0x1f, 0xf3, 0x60, 0xbe, 0x33],
             [0xa1, 0x5f, 0xf7, 0x1d, 0xb4, 0x3e, 0x9b, 0x3c,
              0xe7, 0xbd, 0xb6, 0x06, 0xd5, 0x60, 0x06, 0x6d,
              0x50, 0xd2, 0xf4, 0x1a, 0x31, 0x08, 0xf2, 0xea,
              0x8e, 0xef, 0x5f, 0x7d, 0xb6, 0xd0, 0xc0, 0x27]],
            [[0x62, 0x9a, 0xd9, 0xbb, 0x38, 0x36, 0xce, 0xf7,
              0x5d, 0x2f, 0x13, 0xec, 0xc8, 0x2d, 0x02, 0x8a,
              0x2e, 0x72, 0xf0, 0xe5, 0x15, 0x9d, 0x72, 0xae,
              0xfc, 0xb3, 0x4f, 0x02, 0xea, 0xe1, 0x09, 0xfe],
             [0x00, 0x00, 0x00, 0x00, 0xfa, 0x0a, 0x3d, 0xbc,
              0xad, 0x16, 0x0c, 0xb6, 0xe7, 0x7c, 0x8b, 0x39,
              0x9a, 0x43, 0xbb, 0xe3, 0xc2, 0x55, 0x15, 0x14,
              0x75, 0xac, 0x90, 0x9b, 0x7f, 0x9a, 0x92, 0x00]],
            [[0x8b, 0xac, 0x70, 0x86, 0x29, 0x8f, 0x00, 0x23,
              0x7b, 0x45, 0x30, 0xaa, 0xb8, 0x4c, 0xc7, 0x8d,
              0x4e, 0x47, 0x85, 0xc6, 0x19, 0xe3, 0x96, 0xc2,
              0x9a, 0xa0, 0x12, 0xed, 0x6f, 0xd7, 0x76, 0x16],
             [0x45, 0xaf, 0x7e, 0x33, 0xc7, 0x7f, 0x10, 0x6c,
              0x7c, 0x9f, 0x29, 0xc1, 0xa8, 0x7e, 0x15, 0x84,
              0xe7, 0x7d, 0xc0, 0x6d, 0xab, 0x71, 0x5d, 0xd0,
              0x6b, 0x9f, 0x97, 0xab, 0xcb, 0x51, 0x0c, 0x9f]],
            [[0x9e, 0xc3, 0x92, 0xb4, 0x04, 0x9f, 0xc8, 0xbb,
              0xdd, 0x9e, 0xc6, 0x05, 0xfd, 0x65, 0xec, 0x94,
              0x7f, 0x2c, 0x16, 0xc4, 0x40, 0xac, 0x63, 0x7b,
              0x7d, 0xb8, 0x0c, 0xe4, 0x5b, 0xe3, 0xa7, 0x0e],
             [0x43, 0xf4, 0x44, 0xe8, 0xcc, 0xc8, 0xd4, 0x54,
              0x33, 0x37, 0x50, 0xf2, 0x87, 0x42, 0x2e, 0x00,
              0x49, 0x60, 0x62, 0x02, 0xfd, 0x1a, 0x7c, 0xdb,
              0x29, 0x6c, 0x6d, 0x54, 0x53, 0x08, 0xd1, 0xc8]],
            [[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]],
            [[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]],
            [[0x27, 0x59, 0xc7, 0x35, 0x60, 0x71, 0xa6, 0xf1,
              0x79, 0xa5, 0xfd, 0x79, 0x16, 0xf3, 0x41, 0xf0,
              0x57, 0xb4, 0x02, 0x97, 0x32, 0xe7, 0xde, 0x59,
              0xe2, 0x2d, 0x9b, 0x11, 0xea, 0x2c, 0x35, 0x92],
             [0x27, 0x59, 0xc7, 0x35, 0x60, 0x71, 0xa6, 0xf1,
              0x79, 0xa5, 0xfd, 0x79, 0x16, 0xf3, 0x41, 0xf0,
              0x57, 0xb4, 0x02, 0x97, 0x32, 0xe7, 0xde, 0x59,
              0xe2, 0x2d, 0x9b, 0x11, 0xea, 0x2c, 0x35, 0x92]],
            [[0x28, 0x56, 0xac, 0x0e, 0x4f, 0x98, 0x09, 0xf0,
              0x49, 0xfa, 0x7f, 0x84, 0xac, 0x7e, 0x50, 0x5b,
              0x17, 0x43, 0x14, 0x89, 0x9c, 0x53, 0xa8, 0x94,
              0x30, 0xf2, 0x11, 0x4d, 0x92, 0x14, 0x27, 0xe8],
             [0x39, 0x7a, 0x84, 0x56, 0x79, 0x9d, 0xec, 0x26,
              0x2c, 0x53, 0xc1, 0x94, 0xc9, 0x8d, 0x9e, 0x9d,
              0x32, 0x1f, 0xdd, 0x84, 0x04, 0xe8, 0xe2, 0x0a,
              0x6b, 0xbe, 0xbb, 0x42, 0x40, 0x67, 0x30, 0x6c]],
            [[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
              0x45, 0x51, 0x23, 0x19, 0x50, 0xb7, 0x5f, 0xc4,
              0x40, 0x2d, 0xa1, 0x73, 0x2f, 0xc9, 0xbe, 0xbd],
             [0x27, 0x59, 0xc7, 0x35, 0x60, 0x71, 0xa6, 0xf1,
              0x79, 0xa5, 0xfd, 0x79, 0x16, 0xf3, 0x41, 0xf0,
              0x57, 0xb4, 0x02, 0x97, 0x32, 0xe7, 0xde, 0x59,
              0xe2, 0x2d, 0x9b, 0x11, 0xea, 0x2c, 0x35, 0x92]],
            [[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
              0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe,
              0xba, 0xae, 0xdc, 0xe6, 0xaf, 0x48, 0xa0, 0x3b,
              0xbf, 0xd2, 0x5e, 0x8c, 0xd0, 0x36, 0x41, 0x40],
             [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]],
            [[0x1c, 0xc4, 0xf7, 0xda, 0x0f, 0x65, 0xca, 0x39,
              0x70, 0x52, 0x92, 0x8e, 0xc3, 0xc8, 0x15, 0xea,
              0x7f, 0x10, 0x9e, 0x77, 0x4b, 0x6e, 0x2d, 0xdf,
              0xe8, 0x30, 0x9d, 0xda, 0xe8, 0x9a, 0x65, 0xae],
             [0x02, 0xb0, 0x16, 0xb1, 0x1d, 0xc8, 0x57, 0x7b,
              0xa2, 0x3a, 0xa2, 0xa3, 0x38, 0x5c, 0x8f, 0xeb,
              0x66, 0x37, 0x91, 0xa8, 0x5f, 0xef, 0x04, 0xf6,
              0x59, 0x75, 0xe1, 0xee, 0x92, 0xf6, 0x0e, 0x30]],
            [[0x8d, 0x76, 0x14, 0xa4, 0x14, 0x06, 0x9f, 0x9a,
              0xdf, 0x4a, 0x85, 0xa7, 0x6b, 0xbf, 0x29, 0x6f,
              0xbc, 0x34, 0x87, 0x5d, 0xeb, 0xbb, 0x2e, 0xa9,
              0xc9, 0x1f, 0x58, 0xd6, 0x9a, 0x82, 0xa0, 0x56],
             [0xd4, 0xb9, 0xdb, 0x88, 0x1d, 0x04, 0xe9, 0x93,
              0x8d, 0x3f, 0x20, 0xd5, 0x86, 0xa8, 0x83, 0x07,
              0xdb, 0x09, 0xd8, 0x22, 0x1f, 0x7f, 0xf1, 0x71,
              0xc8, 0xe7, 0x5d, 0x47, 0xaf, 0x8b, 0x72, 0xe9]],
            [[0x83, 0xb9, 0x39, 0xb2, 0xa4, 0xdf, 0x46, 0x87,
              0xc2, 0xb8, 0xf1, 0xe6, 0x4c, 0xd1, 0xe2, 0xa9,
              0xe4, 0x70, 0x30, 0x34, 0xbc, 0x52, 0x7c, 0x55,
              0xa6, 0xec, 0x80, 0xa4, 0xe5, 0xd2, 0xdc, 0x73],
             [0x08, 0xf1, 0x03, 0xcf, 0x16, 0x73, 0xe8, 0x7d,
              0xb6, 0x7e, 0x9b, 0xc0, 0xb4, 0xc2, 0xa5, 0x86,
              0x02, 0x77, 0xd5, 0x27, 0x86, 0xa5, 0x15, 0xfb,
              0xae, 0x9b, 0x8c, 0xa9, 0xf9, 0xf8, 0xa8, 0x4a]],
            [[0x8b, 0x00, 0x49, 0xdb, 0xfa, 0xf0, 0x1b, 0xa2,
              0xed, 0x8a, 0x9a, 0x7a, 0x36, 0x78, 0x4a, 0xc7,
              0xf7, 0xad, 0x39, 0xd0, 0x6c, 0x65, 0x7a, 0x41,
              0xce, 0xd6, 0xd6, 0x4c, 0x20, 0x21, 0x6b, 0xc7],
             [0xc6, 0xca, 0x78, 0x1d, 0x32, 0x6c, 0x6c, 0x06,
              0x91, 0xf2, 0x1a, 0xe8, 0x43, 0x16, 0xea, 0x04,
              0x3c, 0x1f, 0x07, 0x85, 0xf7, 0x09, 0x22, 0x08,
              0xba, 0x13, 0xfd, 0x78, 0x1e, 0x3f, 0x6f, 0x62]],
            [[0x25, 0x9b, 0x7c, 0xb0, 0xac, 0x72, 0x6f, 0xb2,
              0xe3, 0x53, 0x84, 0x7a, 0x1a, 0x9a, 0x98, 0x9b,
              0x44, 0xd3, 0x59, 0xd0, 0x8e, 0x57, 0x41, 0x40,
              0x78, 0xa7, 0x30, 0x2f, 0x4c, 0x9c, 0xb9, 0x68],
             [0xb7, 0x75, 0x03, 0x63, 0x61, 0xc2, 0x48, 0x6e,
              0x12, 0x3d, 0xbf, 0x4b, 0x27, 0xdf, 0xb1, 0x7a,
              0xff, 0x4e, 0x31, 0x07, 0x83, 0xf4, 0x62, 0x5b,
              0x19, 0xa5, 0xac, 0xa0, 0x32, 0x58, 0x0d, 0xa7]],
            [[0x43, 0x4f, 0x10, 0xa4, 0xca, 0xdb, 0x38, 0x67,
              0xfa, 0xae, 0x96, 0xb5, 0x6d, 0x97, 0xff, 0x1f,
              0xb6, 0x83, 0x43, 0xd3, 0xa0, 0x2d, 0x70, 0x7a,
              0x64, 0x05, 0x4c, 0xa7, 0xc1, 0xa5, 0x21, 0x51],
             [0xe4, 0xf1, 0x23, 0x84, 0xe1, 0xb5, 0x9d, 0xf2,
              0xb8, 0x73, 0x8b, 0x45, 0x2b, 0x35, 0x46, 0x38,
              0x10, 0x2b, 0x50, 0xf8, 0x8b, 0x35, 0xcd, 0x34,
              0xc8, 0x0e, 0xf6, 0xdb, 0x09, 0x35, 0xf0, 0xda]],
            [[0xdb, 0x21, 0x5c, 0x8d, 0x83, 0x1d, 0xb3, 0x34,
              0xc7, 0x0e, 0x43, 0xa1, 0x58, 0x79, 0x67, 0x13,
              0x1e, 0x86, 0x5d, 0x89, 0x63, 0xe6, 0x0a, 0x46,
              0x5c, 0x02, 0x97, 0x1b, 0x62, 0x43, 0x86, 0xf5],
             [0xdb, 0x21, 0x5c, 0x8d, 0x83, 0x1d, 0xb3, 0x34,
              0xc7, 0x0e, 0x43, 0xa1, 0x58, 0x79, 0x67, 0x13,
              0x1e, 0x86, 0x5d, 0x89, 0x63, 0xe6, 0x0a, 0x46,
              0x5c, 0x02, 0x97, 0x1b, 0x62, 0x43, 0x86, 0xf5]]
        ];

        uint256 x;
        uint256 y;
        uint256 r1;
        for (uint i = 0; i < 33; i++) {
            (x, ) = scalar.scalar_set_b32(chal[i][0]);
            (y, ) = scalar.scalar_set_b32(chal[i][1]);
            (r1, ) = scalar.scalar_set_b32(res[i][0]);
            uint z = scalar.scalar_mul(x, y);
            assertEqUint(z, r1);

            if (y != 0) {
                uint zz = scalar.scalar_inverse(y);
                uint zm = scalar.scalar_mul(z, zz);
                assertEqUint(x, zm);
                uint zmy = scalar.scalar_mul(zz, y);
                assertEqUint(zmy, 1);
            }
        }
    }
}
