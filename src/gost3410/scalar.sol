// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library scalar {
    uint256 constant SECP256K1_N =
        0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141;

    /* Limbs of the secp256k1 order. */
    uint64 constant SECP256K1_N_0 = 0xBFD25E8CD0364141;
    uint64 constant SECP256K1_N_1 = 0xBAAEDCE6AF48A03B;
    uint64 constant SECP256K1_N_2 = 0xFFFFFFFFFFFFFFFE;
    uint64 constant SECP256K1_N_3 = 0xFFFFFFFFFFFFFFFF;

    /* Limbs of 2^256 minus the secp256k1 order. */
    uint64 constant SECP256K1_N_C_0 = ~SECP256K1_N_0 + 1;
    uint64 constant SECP256K1_N_C_1 = ~SECP256K1_N_1;
    uint64 constant SECP256K1_N_C_2 = 1;

    function scalar_check_overflow(uint256 x) internal pure returns (bool) {
        return x > SECP256K1_N;
    }

    function u128_from_u64(
        uint256 x,
        uint index
    ) internal pure returns (uint128) {
        assert(index <= 4);

        uint shift = 64 * index;
        return uint128(uint64(x >> shift));
    }

    function scalar_set_u64(
        uint256 x,
        uint64 val,
        uint index
    ) internal pure returns (uint256) {
        assert(index <= 4);
        uint256 maskU64 = 0xffffffffffffffff;

        uint shift = (index * 64);

        uint256 valFull = uint256(val) << shift;

        maskU64 = maskU64 << shift;

        return (x & ~maskU64) | (valFull & maskU64); // applying mask on val full is redundant, but keep it
    }

    function u128_to_u64(uint128 x) internal pure returns (uint64) {
        return uint64(x); // drops high bits
    }

    function scalar_to_u64(
        uint256 x,
        uint index
    ) internal pure returns (uint64) {
        uint shift = (index * 64);
        return uint64(x >> shift);
    }

    function u128_accum_u64(
        uint128 a,
        uint64 b
    ) internal pure returns (uint128) {
        return a + b;
    }

    function scalar_reduce(
        uint256 x,
        uint64 overflow
    ) internal pure returns (uint256, uint64) {
        uint128 t;
        uint256 res;

        t = u128_from_u64(x, 0);
        t = u128_accum_u64(t, overflow * SECP256K1_N_C_0);
        res = scalar_set_u64(res, u128_to_u64(t), 0);
        t = t >> 64;

        t = u128_accum_u64(t, scalar_to_u64(x, 1));
        t = u128_accum_u64(t, overflow * SECP256K1_N_C_1);
        res = scalar_set_u64(res, u128_to_u64(t), 1);
        t = t >> 64;

        t = u128_accum_u64(t, scalar_to_u64(x, 2));
        t = u128_accum_u64(t, overflow * SECP256K1_N_C_2);
        res = scalar_set_u64(res, u128_to_u64(t), 2);
        t = t >> 64;

        t = u128_accum_u64(t, scalar_to_u64(x, 3));
        res = scalar_set_u64(res, u128_to_u64(t), 3);

        return (res, overflow);
    }

    function scalar_set_b32(
        uint8[32] memory b32
    ) internal pure returns (uint256 x, uint64 overflow) {
        for (uint i = 0; i < 32; i++) {
            uint shift = (31 - i) * 8;
            x |= (uint256(b32[i]) << shift);
        }
        uint64 over;
        (x, over) = scalar_reduce(x, scalar_check_overflow(x) ? 1 : 0);
        if (overflow != 0) {
            overflow = over;
        }
    }
}