// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "solidity-BigNumber/BigNumbers.sol";

library BNModInverse {
    using BigNumbers for BigNumber;

    function div256(
        BigNumber memory a,
        BigNumber memory b
    ) internal view returns (BigNumber memory) {
        BigNumber memory uintMax = BigNumbers.init(
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            false
        );
        require(a.lte(uintMax), "division operand a is too big");
        require(b.lte(uintMax), "division operand b is too big");
        require(
            a.val.length == 32,
            "operand a value length should be 32 bytes"
        ); // one word (32 bytes)
        require(
            b.val.length == 32,
            "operand b value length should be 32 bytes"
        ); // one word (32 bytes)

        uint aUint;
        uint bUint;

        bytes memory aRaw = a.val;
        bytes memory bRaw = b.val;
        assembly {
            aUint := mload(add(aRaw, 32))
            bUint := mload(add(bRaw, 32))
        }

        uint result = aUint / bUint;
        bool resultNeg = false;
        if (a.neg || b.neg) {
            if (a.neg && b.neg) {} else {
                resultNeg = true;
            }
        }

        return BigNumbers.init(result, resultNeg);
    }

    function divmod(
        BigNumber memory a,
        BigNumber memory b
    ) internal view returns (BigNumber memory, BigNumber memory) {
        BigNumber memory aDivB = div256(a, b);
        BigNumber memory aModB = a.mod(b);
        return (aDivB, aModB);
    }

    /**
     * return (g, x, y) such that a*x + b*y = g = gcd(a, b)
     * alternate implementation of egcd, which uses iteration. xgcd uses more gas.
     */
    function xgcd(
        BigNumber memory a,
        BigNumber memory b
    )
        internal
        view
        returns (BigNumber memory, BigNumber memory, BigNumber memory)
    {
        (
            BigNumber memory x0,
            BigNumber memory x1,
            BigNumber memory y0,
            BigNumber memory y1
        ) = (
                BigNumbers.zero(),
                BigNumbers.one(),
                BigNumbers.one(),
                BigNumbers.zero()
            );

        BigNumber memory zero = BigNumbers.zero();
        BigNumber memory q;
        while (!a.eq(zero)) {
            ((q, a), b) = (divmod(b, a), a);
            (y0, y1) = (y1, y0.sub(q.mul(y1))); // (y0, y1) = (y1, y0 - q * y1)
            (x0, x1) = (x1, x0.sub(q.mul(x1))); // (x0, x1) = (x1, x0 - q * x1)
        }
        return (b, x0, y0);
    }

    /**
     * return x such that (x * a) % b == 1
     */
    function modinv256(
        BigNumber memory a,
        BigNumber memory b
    ) internal view returns (BigNumber memory) {
        (BigNumber memory g, BigNumber memory x, ) = xgcd(a, b);
        assert(g.eq(BigNumbers.one())); // q == 1; modular inverse does not exist

        // return modulo(x, b); // x mod b; double check if mod enough or modulo required
        return x.mod(b);
    }
}
