// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library intModInverse {
    /**
     * modulo operation
     */
    function modulo(int x, int N) internal pure returns (int) {
        // @see https://stackoverflow.com/a/42131603 for details
        return ((x % N) + N) % N;
    }

    function divmod(int a, int b) internal pure returns (int, int) {
        int aDivB = a / b;
        int aModB = modulo(a, b);
        return (aDivB, aModB);
    }

    /**
     * return (g, x, y) such that a*x + b*y = g = gcd(a, b)
     */
    function egcd(int a, int b) internal pure returns (int, int, int) {
        if (a == 0) {
            return (b, 0, 1);
        } else {
            (int bDivA, int bModA) = divmod(b, a);
            (int g, int x, int y) = egcd(bModA, a);
            return (g, y - bDivA * x, x);
        }
    }

    /**
     * return (g, x, y) such that a*x + b*y = g = gcd(a, b)
     * alternate implementation of egcd, which uses iteration. xgcd uses more gas.
     */
    function xgcd(int a, int b) internal pure returns (int, int, int) {
        (int x0, int x1, int y0, int y1) = (0, 1, 1, 0);

        while (a != 0) {
            int q = 0;
            ((q, a), b) = (divmod(b, a), a);
            (y0, y1) = (y1, y0 - q * y1);
            (x0, x1) = (x1, x0 - q * x1);
        }
        return (b, x0, y0);
    }

    /**
     * return x such that (x * a) % b == 1
     */
    function modinv(int a, int b) internal pure returns (int) {
        (int g, int x, ) = xgcd(a, b);
        assert(g == 1); // modular inverse does not exist

        return modulo(x, b);
    }
}
