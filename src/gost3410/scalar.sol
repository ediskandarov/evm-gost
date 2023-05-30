// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./intModInverse.sol";

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

    function scalar_set_s64(
        uint256 x,
        int64 val,
        uint index
    ) internal pure returns (uint256) {
        uint64 val_;
        assembly {
            val_ := val
        }
        return scalar_set_u64(x, val_, index);
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

    function scalar_mul(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 r;
        assembly {
            r := mulmod(x, y, SECP256K1_N)
        }
        return r;
    }

    function scalar_inverse(uint256 x) internal pure returns (uint256) {
        uint256 r = uintModInverse.modinv(x, SECP256K1_N);
        return r;
    }

    function scalar_to_signed62(
        uint256 a
    ) internal pure returns (int64[5] memory) {
        uint64 M62 = type(uint64).max >> 2;
        (uint64 a0, uint64 a1, uint64 a2, uint64 a3) = (
            scalar_to_u64(a, 0),
            scalar_to_u64(a, 1),
            scalar_to_u64(a, 2),
            scalar_to_u64(a, 3)
        );

        int64 r0;
        int64 r1;
        int64 r2;
        int64 r3;
        int64 r4;

        assembly {
            // r->v[0] =  a0                   & M62;
            r0 := and(a0, M62)
            // r->v[1] = (a0 >> 62 | a1 <<  2) & M62;
            r1 := and(or(shr(62, a0), shl(2, a1)), M62)
            // r->v[2] = (a1 >> 60 | a2 <<  4) & M62;
            r2 := and(or(shr(60, a1), shl(4, a2)), M62)
            // r->v[3] = (a2 >> 58 | a3 <<  6) & M62;
            r3 := and(or(shr(58, a2), shl(6, a3)), M62)
            // r->v[4] =  a3 >> 56;
            r4 := shr(56, a3)
        }

        return [r0, r1, r2, r3, r4];
    }

    function scalar_from_signed62(
        int64[5] memory a
    ) internal pure returns (uint256) {
        (int64 a0, int64 a1, int64 a2, int64 a3, int64 a4) = (
            a[0],
            a[1],
            a[2],
            a[3],
            a[4]
        );

        /* The output from secp256k1_modinv64{_var} should be normalized to range [0,modulus), and
         * have limbs in [0,2^62). The modulus is < 2^256, so the top limb must be below 2^(256-62*4).
         */
        assert(a0 >> 62 == 0);
        assert(a1 >> 62 == 0);
        assert(a2 >> 62 == 0);
        assert(a3 >> 62 == 0);
        assert(a4 >> 8 == 0);

        uint256 r;

        r = scalar_set_s64(r, a0 | (a1 << 62), 0);
        r = scalar_set_s64(r, (a1 >> 2) | (a2 << 60), 1);
        r = scalar_set_s64(r, (a2 >> 4) | (a3 << 58), 2);
        r = scalar_set_s64(r, (a3 >> 6) | (a4 << 56), 3);

        return r;
    }

    function u128_hi_u64(uint128 x) internal pure returns (uint64) {
        return uint64(x >> 64);
    }

    function u128_lo_u64(uint128 x) internal pure returns (uint64) {
        return uint64(x);
    }
}
