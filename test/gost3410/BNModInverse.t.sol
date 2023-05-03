// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "solidity-BigNumber/BigNumbers.sol";

import "../../src/gost3410/BNModInverse.sol";

contract intModInverseTest is Test {
    using BigNumbers for BigNumber;
    using BNModInverse for BigNumber;

    function test_BigNumberDiv() external {
        BigNumber memory a = BigNumbers.init(8, false);
        BigNumber memory b = BigNumbers.init(4, false);

        BigNumber memory r = a.div256(b);
        BigNumber memory ref = BigNumbers.two();

        assertTrue(r.eq(ref));
    }

    function test_BigNumberDivNegativeCase1() external {
        BigNumber memory a = BigNumbers.init(8, false);
        BigNumber memory b = BigNumbers.init(4, true);

        BigNumber memory r = a.div256(b);
        BigNumber memory ref = BigNumbers.init(2, true);

        assertTrue(r.eq(ref));
    }

    function test_BigNumberDivNegativeCase2() external {
        BigNumber memory a = BigNumbers.init(8, true);
        BigNumber memory b = BigNumbers.init(4, false);

        BigNumber memory r = a.div256(b);
        BigNumber memory ref = BigNumbers.init(2, true);

        assertTrue(r.eq(ref));
    }

    function test_BigNumberDivNegativeCase3() external {
        BigNumber memory a = BigNumbers.init(8, true);
        BigNumber memory b = BigNumbers.init(4, true);

        BigNumber memory r = a.div256(b);
        BigNumber memory ref = BigNumbers.two();

        assertTrue(r.eq(ref));
    }

    function test_egcd_1() external {
        (
            BigNumber memory g,
            BigNumber memory x,
            BigNumber memory y
        ) = BNModInverse.xgcd(
                BigNumbers.init(23, false),
                BigNumbers.init(97, false)
            );
        assertTrue(g.eq(BigNumbers.one()));
        assertTrue(x.eq(BigNumbers.init(38, false)));
        assertTrue(y.eq(BigNumbers.init(9, true)));
    }

    function test_egcd_2() external {
        (
            BigNumber memory g,
            BigNumber memory x,
            BigNumber memory y
        ) = BNModInverse.xgcd(
                BigNumbers.init(23, false),
                BigNumbers.init(99, false)
            );
        assertTrue(g.eq(BigNumbers.one()));
        assertTrue(x.eq(BigNumbers.init(43, true)));
        assertTrue(y.eq(BigNumbers.init(10, false)));
    }

    function test_egcd_3() external {
        (
            BigNumber memory g,
            BigNumber memory x,
            BigNumber memory y
        ) = BNModInverse.xgcd(
                BigNumbers.init(11, false),
                BigNumbers.init(35, false)
            );
        assertTrue(g.eq(BigNumbers.one()));
        assertTrue(x.eq(BigNumbers.init(16, false)));
        assertTrue(y.eq(BigNumbers.init(5, true)));
    }

    function test_modinv_1() external {
        assertTrue(
            BigNumbers.init(23, false).modinv256(BigNumbers.init(97, false)).eq(
                BigNumbers.init(38, false)
            )
        );
    }

    function test_modinv_2() external {
        assertTrue(
            BigNumbers.init(23, false).modinv256(BigNumbers.init(99, false)).eq(
                BigNumbers.init(56, false)
            )
        );
    }

    function test_modinv_3() external {
        assertTrue(
            BigNumbers.init(11, false).modinv256(BigNumbers.init(35, false)).eq(
                BigNumbers.init(16, false)
            )
        );
        assertTrue(
            BigNumbers.init(38, false).modinv256(BigNumbers.init(93, false)).eq(
                BigNumbers.init(71, false)
            )
        );
    }
}
