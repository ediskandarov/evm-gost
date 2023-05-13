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

    function scalar_mul(uint256 x, uint256 y) internal pure returns (uint256) {
        uint64[8] memory l = scalar_mul_512(x, y);
        uint z = scalar_reduce_512(l);
        return z;
    }

    function scalar_mul_512(
        uint256 a,
        uint256 b
    ) internal pure returns (uint64[8] memory) {
        uint64[8] memory l;
        /* 160 bit accumulator. */
        uint64 c0 = 0;
        uint64 c1 = 0;
        uint64 c2 = 0;

        (c0, c1) = muladd_fast(
            c0,
            c1,
            scalar_to_u64(a, 0),
            scalar_to_u64(b, 0)
        );
        // extract_fast
        (l[0], c0, c1) = (c0, c1, 0);

        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 0),
            scalar_to_u64(b, 1)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 1),
            scalar_to_u64(b, 0)
        );
        // extract
        (l[1], c0, c1, c2) = (c0, c1, c2, 0);

        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 0),
            scalar_to_u64(b, 2)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 1),
            scalar_to_u64(b, 1)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 2),
            scalar_to_u64(b, 0)
        );
        // extract
        (l[2], c0, c1, c2) = (c0, c1, c2, 0);

        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 0),
            scalar_to_u64(b, 3)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 1),
            scalar_to_u64(b, 2)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 2),
            scalar_to_u64(b, 1)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 3),
            scalar_to_u64(b, 0)
        );
        // extract
        (l[3], c0, c1, c2) = (c0, c1, c2, 0);

        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 1),
            scalar_to_u64(b, 3)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 2),
            scalar_to_u64(b, 2)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 3),
            scalar_to_u64(b, 1)
        );
        // extract
        (l[4], c0, c1, c2) = (c0, c1, c2, 0);

        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 2),
            scalar_to_u64(b, 3)
        );
        (c0, c1, c2) = muladd(
            c0,
            c1,
            c2,
            scalar_to_u64(a, 3),
            scalar_to_u64(b, 2)
        );
        // extract
        (l[5], c0, c1, c2) = (c0, c1, c2, 0);

        (c0, c1) = muladd_fast(
            c0,
            c1,
            scalar_to_u64(a, 3),
            scalar_to_u64(b, 3)
        );
        // extract_fast
        (l[6], c0, c1) = (c0, c1, 0);

        l[7] = c0;
        return l;
    }

    function scalar_reduce_512(
        uint64[8] memory l
    ) internal pure returns (uint256) {
        uint128 c128;

        uint64 c_;
        uint64[3] memory c;
        uint64[4] memory n;
        uint64[6] memory m;
        uint64[5] memory p;

        (n[0], n[1], n[2], n[3]) = (l[4], l[5], l[6], l[7]);

        /* Reduce 512 bits into 385. */
        /* m[0..6] = l[0..3] + n[0..3] * SECP256K1_N_C. */
        (c[0], c[1], c[2]) = (l[0], 0, 0);
        (c[0], c[1]) = muladd_fast(c[0], c[1], n[0], SECP256K1_N_C_0);
        // extract_fast
        (m[0], c[0], c[1]) = (c[0], c[1], 0);
    }

    /** Add a*b to the number defined by (c0,c1). c1 must never overflow. */
    function muladd_fast(
        uint64 c0,
        uint64 c1,
        uint64 a,
        uint64 b
    ) internal pure returns (uint64, uint64) {
        uint128 t = uint128(a) * uint128(b);

        uint64 th = u128_hi_u64(t); /* at most 0xFFFFFFFFFFFFFFFE */
        uint64 tl = u128_lo_u64(t);

        unchecked {
            c0 += tl; /* overflow is handled on the next line */
            th += (c0 < tl) ? 1 : 0; /* at most 0xFFFFFFFFFFFFFFFF */
        }
        c1 += th; /* never overflows by contract (verified in the next line) */

        assert(c1 >= th);
        return (c0, c1);
    }

    /** Add a*b to the number defined by (c0,c1,c2). c2 must never overflow. */
    function muladd(
        uint64 c0,
        uint64 c1,
        uint64 c2,
        uint64 a,
        uint64 b
    ) internal pure returns (uint64, uint64, uint64) {
        uint128 t = uint128(a) * uint128(b);

        uint64 th = u128_hi_u64(t); /* at most 0xFFFFFFFFFFFFFFFE */
        uint64 tl = u128_lo_u64(t);

        unchecked {
            c0 += tl; /* overflow is handled on the next line */
            th += (c0 < tl ? 1 : 0); /* at most 0xFFFFFFFFFFFFFFFF */
            c1 += th; /* overflow is handled on the next line */
        }
        c2 += (
            c1 < th ? 1 : 0
        ); /* never overflows by contract (verified in the next line) */

        assert((c1 >= th) || (c2 != 0));
        return (c0, c1, c2);
    }

    /** Add a to the number defined by (c0,c1). c1 must never overflow, c2 must be zero. */
    function sumadd_fast(
        uint64 c0,
        uint64 c1,
        uint64 c2,
        uint64 a
    ) internal pure returns (uint64, uint64, uint64) {
        unchecked {
            c0 += a; /* overflow is handled on the next line */
        }
        c1 += (
            c0 < a ? 1 : 0
        ); /* never overflows by contract (verified the next line) */
        assert((c1 != 0) || (c0 >= a));
        assert(c2 == 0);
        return (c0, c1, c2);
    }

    /** Add a to the number defined by (c0,c1,c2). c2 must never overflow. */
    function sumadd(
        uint64 c0,
        uint64 c1,
        uint64 c2,
        uint64 a
    ) internal pure returns (uint64, uint64, uint64) {
        uint64 over;

        unchecked {
            c0 += a; /* overflow is handled on the next line */
            over = c0 < a ? 1 : 0;
            c1 += over; /* overflow is handled on the next line */
        }
        c2 += c1 < over ? 1 : 0; /* never overflows by contract */

        return (c0, c1, c2);
    }

    function u128_hi_u64(uint128 x) internal pure returns (uint64) {
        return uint64(x >> 64);
    }

    function u128_lo_u64(uint128 x) internal pure returns (uint64) {
        return uint64(x);
    }
}
