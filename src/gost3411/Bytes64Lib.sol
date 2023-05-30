// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Bytes64Lib {
    function initWith01(bytes memory dst) internal pure {
        assert(dst.length % 32 == 0);

        bytes32 pattern = hex"0101010101010101010101010101010101010101010101010101010101010101";
        assembly {
            let len := mload(dst)
            for {
                let offset := 0
            } lt(offset, len) {
                offset := add(offset, 32)
            } {
                mstore(add(add(dst, 32), offset), pattern)
            }
        }
    }

    function replaceAt(
        bytes memory dst,
        uint256 index,
        bytes8 subValue
    ) internal pure {
        // @todo there may be memory corruption
        // there should be enough space to replace
        assert(index <= dst.length - 8);

        assembly {
            // note: first 32 bytes contain the array length
            let offset := add(add(dst, index), 8)

            mstore(
                offset,
                or(
                    // preserve left part of the value
                    and(
                        mload(offset),
                        0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000
                    ),
                    and(
                        shr(192, subValue),
                        0x000000000000000000000000000000000000000000000000ffffffffffffffff
                    )
                )
            )
        }
    }

    function replaceAt(
        bytes memory dst,
        uint256 index,
        uint64 subValue
    ) internal pure {
        // @todo there may be memory corruption
        // there should be enough space to replace
        assert(index <= dst.length - 8);

        assembly {
            // note: first 32 bytes contain the array length
            let offset := add(add(dst, index), 8)

            mstore(
                offset,
                or(
                    // preserve left part of the value
                    and(
                        mload(offset),
                        0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000
                    ),
                    and(
                        subValue,
                        0x000000000000000000000000000000000000000000000000ffffffffffffffff
                    )
                )
            )
        }
    }

    /**
     * Unpack uint64 into 8 uint8 components
     */
    function unpack512(
        bytes memory src
    )
        public
        pure
        returns (
            uint64 r0,
            uint64 r1,
            uint64 r2,
            uint64 r3,
            uint64 r4,
            uint64 r5,
            uint64 r6,
            uint64 r7
        )
    {
        assert(src.length == 64);

        assembly {
            let bytes8mask := 0xffffffffffffffffffffffffffffffff
            // first 32 bytes contains length of array
            let hiR := mload(add(src, 32))
            let loR := mload(add(src, 64))

            // memory allocation: r0 ... r8
            r0 := and(bytes8mask, shr(192, hiR))
            r1 := and(bytes8mask, shr(128, hiR))
            r2 := and(bytes8mask, shr(64, hiR))
            r3 := and(bytes8mask, hiR)

            r4 := and(bytes8mask, shr(192, loR))
            r5 := and(bytes8mask, shr(128, loR))
            r6 := and(bytes8mask, shr(64, loR))
            r7 := and(bytes8mask, loR)
        }
    }

    function copy(
        bytes memory dst,
        bytes memory src,
        uint256 size
    ) internal pure {
        copy(dst, src, size, 0, 0);
    }

    function copy(
        bytes memory dst,
        bytes memory src,
        uint256 size,
        uint256 dstOffset,
        uint256 srcOffset
    ) internal pure {
        // destination array should have enough space to copy to
        assert(dst.length - dstOffset >= size);
        // source array should have enough bytes to copy from
        assert(src.length - srcOffset >= size);
        // destination array length should be divisable by 32
        assert(dst.length % 32 == 0);

        assembly {
            for {
                let offset := 0
            } lt(offset, size) {
                offset := add(offset, 32)
            } {
                let remaining := sub(size, offset)
                let chunk := 0x0

                // if data length to copy is more than or equal 32 bytes
                switch lt(remaining, 32)
                case 0 {
                    chunk := mload(add(add(add(src, 32), srcOffset), offset))
                }
                case 1 {
                    // we should copy a fraction of bytes from src
                    chunk := or(
                        and(
                            mload(add(add(add(dst, 32), dstOffset), offset)),
                            // Move mask right, so that we preserve dst data
                            shr(
                                mul(8, remaining),
                                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                            )
                        ),
                        and(
                            mload(add(add(add(src, 32), srcOffset), offset)),
                            // Move mask left, so that we truncate redundant source data
                            shl(
                                mul(8, sub(32, remaining)),
                                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                            )
                        )
                    )
                }

                // Put chunk into destination
                mstore(add(add(add(dst, 32), dstOffset), offset), chunk)
            }
        }
    }

    function xor512(
        bytes memory dst,
        bytes memory a,
        bytes memory b
    ) internal pure {
        assert(dst.length == 64);
        assert(a.length == 64);
        assert(b.length == 64);

        assembly {
            // xor higher 32 bytes
            mstore(add(dst, 32), xor(mload(add(a, 32)), mload(add(b, 32))))

            // xor lower 32 bytes
            mstore(add(dst, 64), xor(mload(add(a, 64)), mload(add(b, 64))))
        }
    }

    function add512(
        bytes memory dst,
        bytes memory a,
        bytes memory b
    ) internal pure {
        // we can switch implementation here
        // @note: tests do not pass on add512BE implementation
        add512LE(dst, a, b);
    }

    /**
     * Add 512-bit big endian numbers
     */
    function add512BE(
        bytes memory dst,
        bytes memory a,
        bytes memory b
    ) internal pure {
        assert(dst.length == 64);
        assert(a.length == 64);
        assert(b.length == 64);

        assembly {
            // add lower bits of the number
            let loA := mload(add(a, 64))
            let loB := mload(add(b, 64))
            let loR := add(loA, loB) // lower result

            let hiA := mload(add(a, 32))
            let hiB := mload(add(b, 32))

            // add higher bits of the number
            let hiR := add(add(hiA, hiB), lt(loR, loA))

            mstore(add(dst, 64), loR)
            mstore(add(dst, 32), hiR)
        }
    }

    /**
     * Add 512-bit big endian numbers
     */
    function add512LE(
        bytes memory dst,
        bytes memory a,
        bytes memory b
    ) internal pure {
        assert(dst.length == 64);
        assert(a.length == 64);
        assert(b.length == 64);

        // @todo an opportunity for performance(gas usage) optimization
        uint buf = 0;
        for (uint i = 0; i < 64; i++) {
            buf = uint(uint8(a[i])) + uint(uint8(b[i])) + (buf >> 8);
            dst[i] = bytes1(uint8(buf & 0xFF));
        }
    }
}
