// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./BNCurveLib.sol";

contract Gost3410Curve {
    bytes32 public constant GostR3410_2001_ParamSet_cc =
        keccak256("GostR3410_2001_ParamSet_cc");
    bytes32 public constant id_GostR3410_2001_TestParamSet =
        keccak256("id-GostR3410-2001-TestParamSet");
    bytes32 public constant id_tc26_gost_3410_12_256_paramSetA =
        keccak256("id-tc26-gost-3410-12-256-paramSetA");
    bytes32 public constant id_tc26_gost_3410_12_256_paramSetB =
        keccak256("id-tc26-gost-3410-12-256-paramSetB");
    bytes32 public constant id_tc26_gost_3410_12_256_paramSetC =
        keccak256("id-tc26-gost-3410-12-256-paramSetC");
    bytes32 public constant id_tc26_gost_3410_12_256_paramSetD =
        keccak256("id-tc26-gost-3410-12-256-paramSetD");

    constructor() {}

    function getCurve(
        bytes32 curveId
    ) public view returns (CurveLib.Curve memory curve) {
        if (curveId == GostR3410_2001_ParamSet_cc) {
            return
                CurveLib.newCurve({
                    p: 0xC0000000000000000000000000000000000000000000000000000000000003C7,
                    q: 0x5fffffffffffffffffffffffffffffff606117a2f4bde428b7458a54b6e87b85,
                    a: 0xC0000000000000000000000000000000000000000000000000000000000003c4,
                    b: 0x2d06B4265ebc749ff7d0f1f1f88232e81632e9088fd44b7787d5e407e955080c,
                    x: 0x0000000000000000000000000000000000000000000000000000000000000002,
                    y: 0xa20e034bf8813ef5c18d01105e726a17eb248b264ae9706f440bedc8ccb6b22c,
                    cofactor: 1
                });
        } else if (curveId == id_GostR3410_2001_TestParamSet) {
            return
                CurveLib.newCurve({
                    p: 0x8000000000000000000000000000000000000000000000000000000000000431,
                    q: 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3,
                    a: 0x0000000000000000000000000000000000000000000000000000000000000007,
                    b: 0x5FBFF498AA938CE739B8E022FBAFEF40563F6E6A3472FC2A514C0CE9DAE23B7E,
                    x: 0x0000000000000000000000000000000000000000000000000000000000000002,
                    y: 0x08E2A8A0E65147D4BD6316030E16D19C85C97F0A9CA267122B96ABBCEA7E8FC8,
                    cofactor: 1
                });
        } else if (curveId == id_tc26_gost_3410_12_256_paramSetA) {
            return
                CurveLib.newCurve({
                    p: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97,
                    q: 0x400000000000000000000000000000000FD8CDDFC87B6635C115AF556C360C67,
                    a: 0xC2173F1513981673AF4892C23035A27CE25E2013BF95AA33B22C656F277E7335,
                    b: 0x295F9BAE7428ED9CCC20E7C359A9D41A22FCCD9108E17BF7BA9337A6F8AE9513,
                    x: 0x91E38443A5E82C0D880923425712B2BB658B9196932E02C78B2582FE742DAA28,
                    y: 0x32879423AB1A0375895786C4BB46E9565FDE0B5344766740AF268ADB32322E5C,
                    cofactor: 4
                });
        } else if (curveId == id_tc26_gost_3410_12_256_paramSetB) {
            return
                CurveLib.newCurve({
                    p: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97,
                    q: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6C611070995AD10045841B09B761B893,
                    a: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD94,
                    b: 0x00000000000000000000000000000000000000000000000000000000000000a6,
                    x: 0x0000000000000000000000000000000000000000000000000000000000000001,
                    y: 0x8D91E471E0989CDA27DF505A453F2B7635294F2DDF23E3B122ACC99C9E9F1E14,
                    cofactor: 1
                });
        } else if (curveId == id_tc26_gost_3410_12_256_paramSetC) {
            return
                CurveLib.newCurve({
                    p: 0x8000000000000000000000000000000000000000000000000000000000000C99,
                    q: 0x800000000000000000000000000000015F700CFFF1A624E5E497161BCC8A198F,
                    a: 0x8000000000000000000000000000000000000000000000000000000000000C96,
                    b: 0x3E1AF419A269A5F866A7D3C25C3DF80AE979259373FF2B182F49D4CE7E1BBC8B,
                    x: 0x0000000000000000000000000000000000000000000000000000000000000001,
                    y: 0x3FA8124359F96680B83D1C3EB2C070E5C545C9858D03ECFB744BF8D717717EFC,
                    cofactor: 1
                });
        } else if (curveId == id_tc26_gost_3410_12_256_paramSetD) {
            return
                CurveLib.newCurve({
                    p: 0x9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D759B,
                    q: 0x9B9F605F5A858107AB1EC85E6B41C8AA582CA3511EDDFB74F02F3A6598980BB9,
                    a: 0x9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D7598,
                    b: 0x000000000000000000000000000000000000000000000000000000000000805a,
                    x: 0x0000000000000000000000000000000000000000000000000000000000000000,
                    y: 0x41ECE55743711A8C3CBF3783CD08C0EE4D4DC440D4641A8F366E550DFDB3BB67,
                    cofactor: 1
                });
        }
        require(false, "Unknown curve");
    }
}
