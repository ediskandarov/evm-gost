// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library uintModInverse {
    /**
     * modulo operation
     */
    function modulo(uint x, uint N) internal pure returns (uint) {
        // @see https://stackoverflow.com/a/42131603 for details
        return ((x % N) + N) % N;
    }

    function divmod(uint a, uint b) internal pure returns (uint, uint) {
        uint aDivB = a / b;
        uint aModB = modulo(a, b);
        return (aDivB, aModB);
    }

    /**
     * return (g, x, y) such that a*x + b*y = g = gcd(a, b)
     */
    function egcd(uint a, uint b) internal pure returns (uint, uint, uint) {
        if (a == 0) {
            return (b, 0, 1);
        } else {
            (uint bDivA, uint bModA) = divmod(b, a);
            (uint g, uint x, uint y) = egcd(bModA, a);
            return (g, y - bDivA * x, x);
        }
    }

    /**
     * return (g, x, y) such that a*x + b*y = g = gcd(a, b)
     * alternate implementation of egcd, which uses iteration. xgcd uses more gas.
     */
    function xgcd(uint a, uint b) internal pure returns (uint, uint, uint) {
        (uint x0, uint x1, uint y0, uint y1) = (0, 1, 1, 0);

        while (a != 0) {
            uint q = 0;
            ((q, a), b) = (divmod(b, a), a);
            (y0, y1) = (y1, y0 - q * y1);
            (x0, x1) = (x1, x0 - q * x1);
        }
        return (b, x0, y0);
    }

    function bgcd(uint a, uint b) internal pure returns (uint) {
        // Stein's binary GCD algorithm
        // Base cases: gcd(n, 0) = gcd(0, n) = n
        if (a == 0) return b;
        if (b == 0) return a;

        // Extract common factor-2: gcd(2ⁱ n, 2ⁱ m) = 2ⁱ gcd(n, m)
        // and reducing until odd gcd(2ⁱ n, m) = gcd(n, m) if m is odd
        uint k;
        {
            uint k_a = ctz(a);
            uint k_b = ctz(b);

            a >>= k_a;
            b >>= k_b;
            k = (k_a > k_b) ? k_b : k_a;
        }

        while (true) {
            // Invariant: n odd
            assert(a % 2 == 1);
            if (a > b) {
                (a, b) = (b, a);
            }
            b -= a;

            if (b == 0) {
                return a << k;
            }

            b >>= ctz(b);
        }
    }

    function ext_bgcd(
        int256 x,
        int256 y
    ) internal pure returns (int256, int256, int256) {
        int256 v;
        int256 u;
        int256 g = 1;

        while (x % 2 == 0 && y % 2 == 0) {
            x >>= 1;
            y >>= 1;
            g <<= 1;
        }

        (u, v) = (x, y);
        (int A, int B, int C, int D) = (1, 0, 0, 1);

        while (true) {
            while (u % 2 == 0) {
                u >>= 1;
                if (A % 2 == 0 && B % 2 == 0) {
                    A >>= 1;
                    B >>= 1;
                } else {
                    A = (A + y) >> 1;
                    B = (B - x) >> 1;
                }
            }

            while (v % 2 == 0) {
                v >>= 1;
                if (C % 2 == 0 && D % 2 == 0) {
                    C >>= 1;
                    D >>= 1;
                } else {
                    C = (C + y) >> 1;
                    D = (D - x) >> 1;
                }
            }

            if (u >= v) {
                u -= v;
                A -= C;
                B -= D;
            } else {
                v -= u;
                C -= A;
                D -= B;
            }

            if (u == 0) {
                return (C, D, g * v);
            }
        }

        return (0, 0, 0);
    }

    // function ext_bgcd(int256 y, int256 m) internal pure returns (int256) {
    //     (int a, int u, int b, int v) = (y, 1, m, 0);

    //     while (a != 0) {
    //         if (a % 2 == 0) {
    //             // a is even, so this division is exact
    //             a /= 2;
    //             u = (u / 2) % m;
    //         } else {
    //             if (a < b) {
    //                 // conditional swap to ensure a ≥ b
    //                 (a, u, b, v) = (b, v, a, u);
    //             }
    //             // a and b are odd, so this division is exact.
    //             a = (a - b) / 2;
    //             u = ((u - v) / 2) % m;
    //         }
    //     }

    //     if (b != 1) {
    //         // value y is not invertible
    //         return 0;
    //     }

    //     // b contains GCD(y, m) at this point
    //     return v;
    // }

    /* Determine the number of trailing zero bits in a (non-zero) 64-bit x. */
    function ctz(uint a) internal pure returns (uint) {
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

    /**
     * return x such that (x * a) % b == 1
     */
    function modinv(uint a, uint b) internal pure returns (uint) {
        (uint g, uint x, ) = xgcd(a, b);
        assert(g == 1); // modular inverse does not exist

        return modulo(x, b);
    }
}
