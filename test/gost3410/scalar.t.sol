// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost3410/scalar.sol";

contract ScalarTest is Test {
    function test_scalar_mul() external {
        uint256 a = 0xffffffffffffffff8899aabbccddeeff11223344556677889900aabbccddeeff;
        uint256 b = 0xfffe060ef9fb2a32fffe060dfffffe0701f4042a01f1fc19e39c060377f5a697;

        uint256 r = mulmod(a, b, scalar.SECP256K1_N);

        // Result calculated in python (a * b) % SECP256K1_N
        assertEqUint(
            r,
            0x5267cf099f11c32ab5773096c8b2d07c96e4a62c4287583415e2b0367a93a832
        );
    }

    /**
     * backport of `run_scalar_tests` test
     * https://github.com/bitcoin-core/secp256k1/blob/master/src/tests.c#L2343
     */
    function test_scalar() external {
        // values at even indices are X coordinates; odd indices are Y coordinates
        uint256[66] memory chal = [
            0xffff030700000000ffffffffffffff030000000000f8ffffffff0300c0ffffff,
            0xffffffffff0f000000000000000000f8ffffffffffffffffff0300000000e0ff,
            0xefff1f0000000000feffffffffff3f0000000000000000000000000000000000,
            0xffffff000000000000000000000000e0fffffffffcffffffffffffff7f0080ff,
            0xffffff0000000000000000000006000080000080ff3f0000000000f8ffffff00,
            0x0000fcffffffff80ffffffffff0f00e0ffffffffff7f0000000000007fffffff,
            0xffffff00000000000000000080000080ffffffffffffff00001ef8fffffffdff,
            0xffffffffffffff1f000000f8ff0300e0ff0f00000000f0fff3ff030000000000,
            0x80000080ffffff00001c000000ffffffffffffe0ffffff0000000000e0ffffff,
            0xffffffffffff0300f8ffffffffffffffff1f000080ffff3f00feffffffdfffff,
            0xffffffff000ffc9fffffff0080000080ff0ffcff7f00000000f8ffffffffff00,
            0x08000000000000800000f8ff0fc0ffffff1f000000c0ffffffffff0780ffffff,
            0xffffffffff3f000080000080fffffffff7ffffefffffff00ffffff00000000f0,
            0x00000000f8ffffffffffffff01000000000080ffffffffffffffffffffffffff,
            0x00f8ff03ffffff0000feffffffffff0080000080ffffffffffff03c0ff0ffcff,
            0xffffffffffe0ffffff010000003f00c0ffffffffffffffffffffffffffffffff,
            0x8f0f0000000000000000f8ffffffffffff7f000080000080ffffffffffffff00,
            0xffffffffffffffffff0f00000000000000000000000000000000000000000000,
            0x000000c0ffffffffffffffffffffffffffff030080000080ffffff000080ff7f,
            0xffcfffff0100000000c0ffcfffffffffbfff0e000000000080ffffffff000000,
            0x000000000080ffffffff00fcffffffffffffff0080000080ff01fcff0100feff,
            0xffffff0300000000000000000000000000000000000000c0ffffffffffff0300,
            0xffffff0000000000e0ffffffffffffff00f8ffffffffffff7f00000080000080,
            0x000000000000000000f8ff0100f0ffffe0ff0f00000000000000000000000000,
            0xffffffffffffffffff0000000000000000000000000000000000000000f8ff00,
            0xffffffffffff0000fcffff3ff0ffff3f0000f807000000ffffffffff0f7e0000,
            0x00ffffffffffff000000000080000080ffffffffffffffffffff1f0000fe0700,
            0x000000f0fffffffffffffffffffffffffffbff07000000000000000000000060,
            0xff0100ffffff0f00807ffeffffffff0300000000000000000080ffffffffffff,
            0xffff1f00f0ffffffffffffffffffffffffffffffffffffffffffff3f00000000,
            0x80000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            0xfffffffffffffffffffffffffffff1ffffffffffffffff03000000e0ffffffff,
            0xffffffffffffff007e00000000000000c0ffffcfff1f00008000000000000080,
            0x00000000000000000000000000e0ffffffffffffff3f007e0000000000000000,
            0x0000000000000000000000fcffffffffffff0300000000000000000000007c00,
            0x8000000000000080ffff7f0080000000ffffffffffffff000000e0ffffffffff,
            0xffffffffff1f0080ffffffffffffff008000000000000080ffffffffffffff00,
            0xf0ffffffffffffffffffffff3f000080ff0100000000ffffff7ff8ffff1f00fe,
            0xffffff3ff8ffffffff03fe0100000000f0ffffffffffffffffffffffffffff07,
            0xffffffffffffff008000000000000080ffffffff0180ffffffffffffffffff00,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140,
            0x0000000000000000000000000000000000000000000000000000000000000001,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            0xffffffffff0000c0ff0f0000000000000000f0ffffffffffffffffffffffff7f,
            0xffffffffffff0100f0ffffffff070000000000feffffffffffffffff01ffffff,
            0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            0x0000000000000000000000000000000000000000000000000000000000000002,
            0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140,
            0x0000000000000000000000000000000000000000000000000000000000000001,
            0xffffffffffffffff7e0000c0ffff07008000000080000000fcffffffffffffff,
            0xff01000000e0ffffffffffffff1f0080ffffffffff030000ffffffffffffffff,
            0xfffff0ffffffff00f0ffffffffffff0000e0ffffffffff0180000080ffffffff,
            0x0000000000e0ffffffff3f00f8ffffffffffffffffffffffff3f0000c0f17f00,
            0xffffff0000000000000000c0ffffffffffffff000000000080000080ffffff00,
            0x00f8ffffffffff01000000000000f8ffff7f00000000801f0000fcffff01ffff,
            0x00feffffffffff0080000080ff03e001ffffff000000fcffffffffffffffff00,
            0xffffffff00000000fefffff007003c80fffffffffcffffffffff07e0ff000000,
            0xffffffffffffff00fcffffffffffffffffffffffffff07f80000000080000080,
            0xffffffffffffffffffffffffff0c8000000000c07ffeff1f00feff030000feff,
            0xffff81ffffffff0080ffffffffffff83ffff000080000080ffff7f00000000f0,
            0xff0100000000f8ffffffffffff1f0000f8070080ffffffffffc7ffffe0ffffff,
            0x82c9fab06804a00082c9fab06804a000ffffffffff6f03fbfa8a7ddf1386e203,
            0x82c9fab06804a00082c9fab06804a000ffffffffff6f03fbfa8a7ddf1386e203
        ];
        // values at even indices are r1; odd indices are r2
        uint256[66] memory res = [
            0x0c3b0aca8d1a2fb98a7b535a1fc522a1072a48ea02ebb3d6201e86d095f69235,
            0xdc907a072e1e446df815245b5a96379c377b0dac1b65584943b731bba7f49715,
            0xf1f73a50e610ba22434d1f1f7c27ca9cb8b6a0fcd8c0052ff708e176ddd080c8,
            0xe38080b8dbe3a97700b0f52e27e268c488e804c112bf7859e6a97ce181ddb9d5,
            0x96e2ee01a68031ef5cd019b47d5f79aba197d37e33bb86556020100d942d117c,
            0xccabe0e898651296385a1af28523595ff9f3c281709265129c651e9600efe763,
            0xac1e62c259fc4e5c83b0d06fce19f6bfa4b0e053661fbfc9334737a93d5db048,
            0x86b92a7f8ea86042266d6e1ca2ece0e53e0a33bb614c9f3cd1df4933cd727818,
            0xf7d3cd495c1322fb2eb22f27f58a5d74c158c5c22d9f52c6639fba0576457a63,
            0x8afa554ddda3b2c344fdec72deefc099f59fe252b405325857c18feac3245b94,
            0x0583eedd64f0143ba0144a3a41827ca72caab176bb59645f52ad25299d8f0bb0,
            0x7ee37ccacd4fb06d7ab23ea008b9a82dc2f49966ccacd8b9722a4a3e0f7bbff4,
            0x8c9c782b39617ef76537660938b96f707887ffcf93ca85064484a7fed3a4e37e,
            0xa256492354a550e95ff04de7dc3832794f1cb7e4bbf8bb2e40414bcce31e1636,
            0x0c1ed709254097cb5c46a8daef25d5e5924dcfa3c45d354ae46192f3bf0ecdbe,
            0xe4af0ab3308b9b484943c764604a2b9e955f56e835dcebdcc7c4fe3040c7bfa4,
            0xd4a0f581496bb68b0a69f9fea832e5e0a5cd0253f92ce3538336c602b5eb64b8,
            0x1d42b9f9e9e3932c4cee6c5a479e62016b04fea4302b0d4f7110d355caf35e80,
            0x7705f60c159b45e7b911b8f5d6da730cda92ead09dd01892ce9aaaee0fefde30,
            0xf1f1d69b51d777625210b87a849d154e07dc1e750d0c3bdb7458620290548b43,
            0xa6fe0b8780436725575dec405008d55d43d7e0aae013b6b0c0d4e50d4583d613,
            0x40450a9231ea8c608c1fd87645b929002632d8a69688e2c48bdb7f1787ccc8f2,
            0xc256e2b61a81e731632ebb0d2f8167d422e238022597c7886edfbe2aa57363aa,
            0x5045e2c3bd89fc57bd3ca3987e7f363892391f0f811a06511f8d6aff4716069c,
            0x3395a26f275f9c9c6445cbd13cee5e5f48a6afe379cfb1e2bf550ea23b62f0e4,
            0x14e806e3be7e6701c52167d854b57fa4f975701cfd79db86ad378583564ef0bf,
            0xbca6e0564eeffaf51d5d3f2a5b19ab51c58bdd9828352fc3814f5ce570b9eb62,
            0xc46d26b0176bfe6c12f8e7c1f52ffa911327bd73cc33311c39e3276a95cfc5fb,
            0x30b29984f0182a6e1e27eda229994156e8d40def999cf35829551ac068d674a4,
            0x079ce7ecf5367341a31ce593976afdf75318abafeb85bd9290ab3cbf3082adf6,
            0xc6878a2aeac0a9ec6dd3dc3223ce6219a47ea8dd1c33aed34f629f52e76546f4,
            0x975127672da2828798d3b6147f51d39a0bd07681b24f5892a486a1a7091def9b,
            0xb30f2b690d069064bd434c10e8981ca3e168e9796c29513f41dcdf1ff360be33,
            0xa15ff71db43e9b3ce7bdb606d560066d50d2f41a3108f2ea8eef5f7db6d0c027,
            0x629ad9bb3836cef75d2f13ecc82d028a2e72f0e5159d72aefcb34f02eae109fe,
            0x00000000fa0a3dbcad160cb6e77c8b399a43bbe3c255151475ac909b7f9a9200,
            0x8bac7086298f00237b4530aab84cc78d4e4785c619e396c29aa012ed6fd77616,
            0x45af7e33c77f106c7c9f29c1a87e1584e77dc06dab715dd06b9f97abcb510c9f,
            0x9ec392b4049fc8bbdd9ec605fd65ec947f2c16c440ac637b7db80ce45be3a70e,
            0x43f444e8ccc8d454333750f287422e0049606202fd1a7cdb296c6d545308d1c8,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000001,
            0x2759c7356071a6f179a5fd7916f341f057b4029732e7de59e22d9b11ea2c3592,
            0x2759c7356071a6f179a5fd7916f341f057b4029732e7de59e22d9b11ea2c3592,
            0x2856ac0e4f9809f049fa7f84ac7e505b174314899c53a89430f2114d921427e8,
            0x397a8456799dec262c53c194c98d9e9d321fdd8404e8e20a6bbebb424067306c,
            0x000000000000000000000000000000014551231950b75fc4402da1732fc9bebd,
            0x2759c7356071a6f179a5fd7916f341f057b4029732e7de59e22d9b11ea2c3592,
            0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140,
            0x0000000000000000000000000000000000000000000000000000000000000001,
            0x1cc4f7da0f65ca397052928ec3c815ea7f109e774b6e2ddfe8309ddae89a65ae,
            0x02b016b11dc8577ba23aa2a3385c8feb663791a85fef04f65975e1ee92f60e30,
            0x8d7614a414069f9adf4a85a76bbf296fbc34875debbb2ea9c91f58d69a82a056,
            0xd4b9db881d04e9938d3f20d586a88307db09d8221f7ff171c8e75d47af8b72e9,
            0x83b939b2a4df4687c2b8f1e64cd1e2a9e4703034bc527c55a6ec80a4e5d2dc73,
            0x08f103cf1673e87db67e9bc0b4c2a5860277d52786a515fbae9b8ca9f9f8a84a,
            0x8b0049dbfaf01ba2ed8a9a7a36784ac7f7ad39d06c657a41ced6d64c20216bc7,
            0xc6ca781d326c6c0691f21ae84316ea043c1f0785f7092208ba13fd781e3f6f62,
            0x259b7cb0ac726fb2e353847a1a9a989b44d359d08e57414078a7302f4c9cb968,
            0xb775036361c2486e123dbf4b27dfb17aff4e310783f4625b19a5aca032580da7,
            0x434f10a4cadb3867faae96b56d97ff1fb68343d3a02d707a64054ca7c1a52151,
            0xe4f12384e1b59df2b8738b452b354638102b50f88b35cd34c80ef6db0935f0da,
            0xdb215c8d831db334c70e43a1587967131e865d8963e60a465c02971b624386f5,
            0xdb215c8d831db334c70e43a1587967131e865d8963e60a465c02971b624386f5
        ];

        uint256 x;
        uint256 y;
        uint256 r1;
        for (uint i = 0; i < 33; i++) {
            x = chal[i * 2];
            y = chal[i * 2 + 1];
            r1 = res[i * 2];

            uint z = scalar.scalar_mul(x, y);
            assertEqUint(z, r1);

            if (y != 0) {
                uint zz = scalar.scalar_inverse(y);
                uint zm = scalar.scalar_mul(z, zz);
                assertEqUint(x, zm);
                uint zmy = scalar.scalar_mul(zz, y);
                assertEqUint(zmy, 1);
            }
        }
    }
}
