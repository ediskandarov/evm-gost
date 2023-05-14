// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library modinv64 {
    struct modinv64_modinfo {
        /* The modulus in signed62 notation, must be odd and in [3, 2^256]. */
        int64[5] modulus;
        /* modulus^{-1} mod 2^62 */
        uint64 modulus_inv62;
    }

    /* Data type for transition matrices (see section 3 of explanation).
     *
     * t = [ u  v ]
     *     [ q  r ]
     */
    struct trans2x2 {
        int64 u;
        int64 v;
        int64 q;
        int64 r;
    }

    /* Replace x with its modular inverse mod modinfo->modulus. x must be in range [0, modulus).
     * If x is zero, the result will be zero as well. If not, the inverse must exist (i.e., the gcd of
     * x and modulus must be 1). These rules are automatically satisfied if the modulus is prime.
     *
     * On output, all of x's limbs will be in [0, 2^62).
     */
    function modinv64_(
        int64[5] memory x,
        modinv64_modinfo memory modinfo
    ) internal pure returns (uint256) {
        /* Start with d=0, e=1, f=modulus, g=x, eta=-1. */
        int64[5] memory d = [int64(0), 0, 0, 0, 0];
        int64[5] memory e = [int64(1), 0, 0, 0, 0];
        int64[5] memory f = modinfo.modulus;
        int64[5] memory g = x;

        int j;
        int len = 5;
        int eta = -1; /* eta = -delta; delta is initially 1 */
        int cond;
        int fn;
        int gn;

        /* Do iterations of 62 divsteps each until g=0. */
        while (true) {
            /* Compute transition matrix and new eta after 62 divsteps. */
            trans2x2 memory t;
            // eta = 0;
        }
    }

    /* Compute the transition matrix and eta for 62 divsteps (variable time, eta=-delta).
     *
     * Input:  eta: initial eta
     *         f0:  bottom limb of initial f
     *         g0:  bottom limb of initial g
     * Output: t: transition matrix
     * Return: final eta
     *
     * Implements the divsteps_n_matrix_var function from the explanation.
     */
    function divsteps_62(
        int eta,
        uint64 f0,
        uint64 g0
    ) internal pure returns (int, trans2x2 memory) {
        /* Transformation matrix; see comments in secp256k1_modinv64_divsteps_62. */
        (uint64 u, uint64 v, uint64 q, uint64 r) = (1, 0, 0, 1);
        (uint64 f, uint64 g, uint64 m) = (f0, g0, 0);
        uint32 w;
        uint i = 62;
        uint limit;
        uint zeros;

        while (true) {
            /* Use a sentinel bit to count zeros only up to i. */
            zeros = ctz64(g | uint64((0xffffffffffffffff << i)));
            /* Perform zeros divsteps at once; they all just divide g by two. */
            g >>= zeros;
            u <<= zeros;
            v <<= zeros;
            eta -= int(zeros);
            i -= zeros;
            /* We're done once we've done 62 divsteps. */
            if (i == 0) break;
            assert((f & 1) == 1);
            assert((g & 1) == 1);
            assert((u * f0 + v * g0) == (f << (62 - i)));
            assert((q * f0 + r * g0) == (g << (62 - i)));
            /* Bounds on eta that follow from the bounds on iteration count (max 12*62 divsteps). */
            assert((eta >= -745) && (eta <= 745));
            if (eta < 0) {
                uint64 tmp;
                eta = -eta;
                (tmp, f, g) = (f, g, negate_u64(tmp));
                (tmp, u, q) = (u, q, negate_u64(tmp));
                (tmp, v, r) = (v, r, negate_u64(tmp));
                /* Use a formula to cancel out up to 6 bits of g. Also, no more than i can be cancelled
                 * out (as we'd be done before that point), and no more than eta+1 can be done as its
                 * sign will flip again once that happens. */
                limit = (eta + 1) > int(i) ? i : uint(eta + 1);
                assert(limit > 0 && limit <= 62);
                /* m is a mask for the bottom min(limit, 6) bits. */
                m = (type(uint64).max >> uint64(64 - limit)) & 63;
                /* Find what multiple of f must be added to g to cancel its bottom min(limit, 6)
                 * bits. */
                w = uint32((f * g * (f * f - 2)) & m);
            } else {
                /* In this branch, use a simpler formula that only lets us cancel up to 4 bits of g, as
                 * eta tends to be smaller here. */
                limit = (eta + 1) > int(i) ? i : uint(eta + 1);
                assert(limit > 0 && limit <= 62);
                /* m is a mask for the bottom min(limit, 4) bits. */
                m = (type(uint64).max >> (64 - limit)) & 15;
                /* Find what multiple of f must be added to g to cancel its bottom min(limit, 4)
                 * bits. */
                w = uint32(f + (((f + 1) & 4) << 1));
                w = uint32((negate_u32(w) * g) & m);
            }
            g += f * w;
            q += u * w;
            r += v * w;
            assert((g & m) == 0);
        }

        // return (eta, trans2x2({u: u, v: v, q: q, r: r}));
    }

    /* Determine the number of trailing zero bits in a (non-zero) 64-bit x. */
    function ctz64(uint64 a) internal pure returns (uint) {
        // @todo this algorithm could be optimized
        uint counter = 0;
        for (uint i = 0; i < 64; i++) {
            if ((a >> i) & 1 == 0) {
                counter += 1;
            } else {
                break;
            }
        }
        return counter;
    }

    function negate_u64(uint64 x) internal pure returns (uint64) {
        uint64 r;
        unchecked {
            r = 0 - x;
        }
        return r;
    }

    function negate_u32(uint32 x) internal pure returns (uint32) {
        uint32 r;
        unchecked {
            r = 0 - x;
        }
        return r;
    }
}
