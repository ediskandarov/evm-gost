// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost/Bytes64Lib.sol";

contract TestBytes64LibTest is Test {
    using Bytes64Lib for bytes;

    constructor() {}

    function test_init() external {
        bytes memory value = new bytes(64);

        assertEq(
            value,
            hex"0000000000000000000000000000000000000000000000000000000000000000"
            hex"0000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    function test_initWith01() external {
        bytes memory value = new bytes(64);

        value.initWith01();

        assertEq(
            value,
            hex"0101010101010101010101010101010101010101010101010101010101010101"
            hex"0101010101010101010101010101010101010101010101010101010101010101"
        );
    }

    function test_replaceByteAtIndex() external {
        bytes memory value = new bytes(64);
        value.initWith01();

        value[1] = hex"ff";

        assertEq(
            value,
            hex"01ff010101010101010101010101010101010101010101010101010101010101"
            hex"0101010101010101010101010101010101010101010101010101010101010101"
        );
    }

    function test_replaceUint64AtIndex() external {
        bytes memory value = new bytes(64);
        value.initWith01();

        value.replaceAt(1, bytes8(0x1234567890abcdef));

        assertEq(
            value,
            hex"011234567890abcdef0101010101010101010101010101010101010101010101"
            hex"0101010101010101010101010101010101010101010101010101010101010101"
        );
    }

    function test_copySmallString() external {
        string memory message = "hello world";
        bytes memory value = new bytes(64);
        value.initWith01();

        bytes memory subValue = bytes(message);

        value.copy(subValue, subValue.length);

        assertEq(
            value,
            hex"68656c6c6f20776f726c64010101010101010101010101010101010101010101"
            hex"0101010101010101010101010101010101010101010101010101010101010101"
        );
    }

    function test_copyLargeString() external {
        string memory message = "The quick brown fox jumps over the lazy dog";
        bytes memory value = new bytes(64);
        value.initWith01();

        bytes memory subValue = bytes(message);

        value.copy(subValue, subValue.length);

        assertEq(
            value,
            hex"54686520717569636b2062726f776e20666f78206a756d7073206f7665722074"
            hex"6865206c617a7920646f67010101010101010101010101010101010101010101"
        );
    }

    function test_copyLargeStringWithDestinationOffset() external {
        string memory message = "The quick brown fox jumps over the lazy dog";
        bytes memory value = new bytes(64);
        value.initWith01();

        bytes memory subValue = bytes(message);

        value.copy(subValue, subValue.length, 2, 0);

        assertEq(
            value,
            hex"010154686520717569636b2062726f776e20666f78206a756d7073206f766572"
            hex"20746865206c617a7920646f6701010101010101010101010101010101010101"
        );
    }

    function test_copyLargeStringWithDestinationAndSourceOffset() external {
        string memory message = "The quick brown fox jumps over the lazy dog";
        bytes memory value = new bytes(64);
        value.initWith01();

        bytes memory subValue = bytes(message);

        value.copy(subValue, subValue.length - 10, 2, 10);

        assertEq(
            value,
            hex"010162726f776e20666f78206a756d7073206f76657220746865206c617a7920"
            hex"646f670101010101010101010101010101010101010101010101010101010101"
        );
    }

    function test_xor512OnItselfShouldBeZeroBytes() external {
        bytes memory dst = new bytes(64);

        bytes memory a = new bytes(64);
        a.initWith01();

        bytes memory b = new bytes(64);
        b.initWith01();

        dst.xor512(a, b);

        assertEq(
            dst,
            hex"0000000000000000000000000000000000000000000000000000000000000000"
            hex"0000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    function test_xor512OnZeroBytes() external {
        bytes memory dst = new bytes(64);

        bytes memory a = new bytes(64);
        a.initWith01();

        // b remains zero initialized
        bytes memory b = new bytes(64);

        dst.xor512(a, b);

        assertEq(
            dst,
            hex"0101010101010101010101010101010101010101010101010101010101010101"
            hex"0101010101010101010101010101010101010101010101010101010101010101"
        );
    }

    function test_add512() external {
        bytes memory dst = new bytes(64);

        dst.add512(
            hex"0101010101010101010101010101010101010101010101010101010101010101"
            hex"0101010101010101010101010101010101010101010101010101010101010101",
            hex"0101010101010101010101010101010101010101010101010101010101010101"
            hex"0101010101010101010101010101010101010101010101010101010101010101"
        );

        assertEq(
            dst,
            hex"0202020202020202020202020202020202020202020202020202020202020202"
            hex"0202020202020202020202020202020202020202020202020202020202020202"
        );

        dst.add512(
            hex"0101010101010101010101010101010101010101010101010101010101010101"
            hex"0101010101010101010101010101010101010101010101010101010101010101",
            hex"0101010101010101010101010101010101010101010101010101010101010101"
            hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        );

        assertEq(
            dst,
            hex"0202020202020202020202020202020202020202020202020202020202020203"
            hex"0101010101010101010101010101010101010101010101010101010101010100"
        );
    }

    function test_unpack512() external {
        bytes memory val = new bytes(64);
        val.copy(
            hex"0000000000000000111111111111111122222222222222223333333333333333"
            hex"4444444444444444555555555555555566666666666666667777777777777777",
            64
        );

        (
            uint64 r0,
            uint64 r1,
            uint64 r2,
            uint64 r3,
            uint64 r4,
            uint64 r5,
            uint64 r6,
            uint64 r7
        ) = val.unpack512();

        assertEq(r0, uint256(0x0000000000000000));
        assertEq(r1, uint256(0x1111111111111111));
        assertEq(r2, uint256(0x2222222222222222));
        assertEq(r3, uint256(0x3333333333333333));
        assertEq(r4, uint256(0x4444444444444444));
        assertEq(r5, uint256(0x5555555555555555));
        assertEq(r6, uint256(0x6666666666666666));
        assertEq(r7, uint256(0x7777777777777777));
    }
}
