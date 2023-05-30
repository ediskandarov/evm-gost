// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library uintModInverse {
    function ext_bgcd(
        uint256 y,
        uint256 m
    ) internal pure returns (uint256, uint256) {
        assert(m >= 3);
        assert(m % 2 == 1);
        assert(y >= 0);
        assert(y < m);
        uint a;
        uint b;
        uint u;
        uint v;

        (a, u, b, v) = (y, 1, m, 0);

        while (a != 0) {
            while (a & 1 == 0) {
                a >>= 1;
                if (u & 1 == 0) {
                    u = (u >> 1) % m;
                } else {
                    // @todo double check if its correct to add +1 outside of addmod
                    // the way it works is this:
                    // u = ((u + m) / 2) % m
                    // u = (u / 2 + m / 2) % m
                    // we know that both `u` and `m` are odd
                    // u = ((u - 1) / 2 + (m - 1) / 2 + (1 + 1) / 2) % m
                    // u = ((u - 1) / 2 + (m - 1) / 2 + 1) % m
                    // upon division, u / 2 loses 0.5 on rounding
                    u = (addmod(u >> 1, m >> 1, m) + 1) % m; // u = ((u + m) / 2) % m
                }
            }

            while (b & 1 == 0) {
                b >>= 1;
                if (v & 1 == 0) {
                    v = (v >> 1) % m;
                } else {
                    v = (addmod(v >> 1, m >> 1, m) + 1) % m; // v = ((v + m) / 2) % m
                }
            }

            if (a < b) {
                (a, u, b, v) = (b, v, a, u);
            }

            a -= b;
            // u = (u - v) % m
            if (u > v) {
                u = (u - v) % m;
            } else {
                // @todo double check if it works in all cases
                uint diffRem = (v - u) % m;
                u = m - diffRem;
            }
        }

        return (b, v);
    }

    /**
     * return x such that (x * a) % b == 1
     */
    function modinv(uint a, uint b) internal pure returns (uint) {
        (uint g, uint x) = ext_bgcd(a, b);
        assert(g == 1); // modular inverse exists check

        return x;
    }
}
