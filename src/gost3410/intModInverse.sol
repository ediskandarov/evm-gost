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

    function modulo_v2(uint x, bool sign, uint n) internal pure returns (uint) {
        uint rem = x % n;
        if (sign || rem == 0) {
            // x is positive number or 0
            return rem;
        } else {
            // x is negative
            return n - rem;
        }
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

    /**
     * v2 version of extended binary GCD algorythms
     *
     * Difference v1...v2:
     *
     * 1. use unsigned int instead of signed int
     *    - this change required storing signs of some vars separately
     * 2. do not calculate B and D vars, at they are not used
     * 3. move loop stop check loop clause
     */
    function ext_bgcd_v2(
        uint256 x,
        uint256 y
    ) internal pure returns (uint256, uint256, bool) {
        uint256 v;
        uint256 u;
        uint256 g = 1;

        while (x % 2 == 0 && y % 2 == 0) {
            x >>= 1;
            y >>= 1;
            g <<= 1;
        }

        (u, v) = (x, y);
        (uint A, uint C) = (1, 0);
        (bool aSign, bool cSign) = (true, true);

        while (u != 0) {
            while (u % 2 == 0) {
                u >>= 1;
                if (A % 2 == 0) {
                    A >>= 1;
                } else {
                    (A, aSign) = _add(A, aSign, y, true); // A = A + y
                    A >>= 1;
                }
            }

            while (v % 2 == 0) {
                v >>= 1;
                if (C % 2 == 0) {
                    C >>= 1;
                } else {
                    (C, cSign) = _add(C, cSign, y, true); // C = C + y
                    C >>= 1;
                }
            }

            if (u >= v) {
                u -= v;
                (A, aSign) = _add(A, aSign, C, !cSign); // A = A - C
            } else {
                v -= u;
                (C, cSign) = _add(C, cSign, A, !aSign); // C = C - A
            }
        }

        return (g * v, C, cSign);
    }

    /**
     * v3 version of extended binary GCD algorythms
     *
     * Difference v2...v3:
     * 1. unify variables with https://eprint.iacr.org/2020/972.pdf algorythm
     * 2. apply requirements
     * 3. remove optimization for trailing zeros
     * 4. replace condition with variables swapping
     */
    function ext_bgcd_v3(
        uint256 y,
        uint256 m
    ) internal pure returns (uint256, uint256, bool) {
        assert(m >= 3);
        assert(m % 2 == 1);
        assert(y >= 0);
        assert(y < m);
        uint a;
        uint b;
        uint u;
        uint v;

        (a, u, b, v) = (y, 1, m, 0);
        (bool uSign, bool vSign) = (true, true);

        while (a != 0) {
            while (a % 2 == 0) {
                a >>= 1;
                if (u % 2 == 0) {
                    u >>= 1;
                } else {
                    (u, uSign) = _add(u, uSign, m, true); // u = u + m
                    u >>= 1;
                }
            }

            while (b % 2 == 0) {
                b >>= 1;
                if (v % 2 == 0) {
                    v >>= 1;
                } else {
                    (v, vSign) = _add(v, vSign, m, true); // v = v + m
                    v >>= 1;
                }
            }

            if (a < b) {
                (a, u, b, v) = (b, v, a, u);
            }

            a -= b;
            (u, uSign) = _add(u, uSign, v, !vSign); // u = u - v
        }

        return (b, v, vSign);
    }

    function _add(
        uint256 x,
        bool isXPositive,
        uint256 y,
        bool isYPositive
    ) internal pure returns (uint256, bool) {
        if (isXPositive && isYPositive) {
            // both values are positive
            return (x + y, true);
        } else if (!isXPositive && !isYPositive) {
            // both values are negative;
            return (x + y, false);
        } else if (!isXPositive && isYPositive) {
            // x is negative, y is positive
            if (x > y) {
                // x is negative and its greater than y; result is negative
                return (x - y, false);
            } else {
                // x is negative and its less than y; result is positive
                return (y - x, true);
            }
        } else {
            // x is positive, y is negative
            if (x > y) {
                // x is positive and its greater than y; result is positive
                return (x - y, true);
            } else {
                // x is positive and its less than y; result is negative
                return (y - x, false);
            }
        }
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
        (uint g, uint x, bool xIsPositive) = ext_bgcd_v2(a, b);
        assert(g == 1); // modular inverse exists check

        return modulo_v2(x, xIsPositive, b);
    }
}
