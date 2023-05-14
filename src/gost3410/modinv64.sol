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
    struct modinv64_trans2x2 {
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
            modinv64_trans2x2 memory t;
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
        int64 eta,
        uint64 f0,
        uint64 g0
    ) internal pure returns (modinv64_trans2x2 memory) {
        /* Transformation matrix; see comments in secp256k1_modinv64_divsteps_62. */
        (uint64 u, uint64 v, uint64 q, uint64 r) = (1, 0, 0, 1);
        (uint64 f, uint64 g, uint64 m) = (f0, g0, 0);
        uint32 w;
        int i = 62;
        int limit;
        int zeros;

        while (true) {
            /* Use a sentinel bit to count zeros only up to i. */
        }
    }

    /* Determine the number of trailing zero bits in a (non-zero) 64-bit x. */
    function ctz64(uint64) internal pure returns (int) {}
}
