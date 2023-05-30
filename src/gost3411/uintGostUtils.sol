// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library uintGostUtils {
    /**
     * swaps bytes in 64bit number
     * 0x1122334455667788 -> 0x8877665544332211
     */
    function bswap64(uint x) internal pure returns (uint64 result) {
        assembly {
            result := or(
                or(
                    or(
                        or(
                            or(
                                or(
                                    or(
                                        shr(56, and(x, 0xFF00000000000000)),
                                        shr(40, and(x, 0x00FF000000000000))
                                    ),
                                    shr(24, and(x, 0x0000FF0000000000))
                                ),
                                shr(8, and(x, 0x000000FF00000000))
                            ),
                            shl(8, and(x, 0x00000000FF000000))
                        ),
                        shl(24, and(x, 0x0000000000FF0000))
                    ),
                    shl(40, and(x, 0x000000000000FF00))
                ),
                shl(56, and(x, 0x00000000000000FF))
            )
        }
    }
}
