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
