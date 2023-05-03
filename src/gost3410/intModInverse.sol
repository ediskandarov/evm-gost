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

    /**
     * return x such that (x * a) % b == 1
     */
    function modinv(uint a, uint b) internal pure returns (uint) {
        (uint g, uint x, ) = xgcd(a, b);
        assert(g == 1); // modular inverse does not exist

        return modulo(x, b);
    }
}
