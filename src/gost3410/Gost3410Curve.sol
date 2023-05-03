// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./CurveLib.sol";

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
    ) internal pure returns (CurveLib.Curve memory curve) {
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
            // "id-GostR3410-2001-TestParamSet": GOST3410Curve(
            //     p=bytes2long(hexdec("8000000000000000000000000000000000000000000000000000000000000431")),
            //     q=bytes2long(hexdec("8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3")),
            //     a=bytes2long(hexdec("0000000000000000000000000000000000000000000000000000000000000007")),
            //     b=bytes2long(hexdec("5FBFF498AA938CE739B8E022FBAFEF40563F6E6A3472FC2A514C0CE9DAE23B7E")),
            //     x=bytes2long(hexdec("0000000000000000000000000000000000000000000000000000000000000002")),
            //     y=bytes2long(hexdec("08E2A8A0E65147D4BD6316030E16D19C85C97F0A9CA267122B96ABBCEA7E8FC8")),
            // ),
        } else if (curveId == id_tc26_gost_3410_12_256_paramSetA) {
            // "id-tc26-gost-3410-12-256-paramSetA": GOST3410Curve(
            //     p=bytes2long(hexdec("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97")),
            //     q=bytes2long(hexdec("400000000000000000000000000000000FD8CDDFC87B6635C115AF556C360C67")),
            //     a=bytes2long(hexdec("C2173F1513981673AF4892C23035A27CE25E2013BF95AA33B22C656F277E7335")),
            //     b=bytes2long(hexdec("295F9BAE7428ED9CCC20E7C359A9D41A22FCCD9108E17BF7BA9337A6F8AE9513")),
            //     x=bytes2long(hexdec("91E38443A5E82C0D880923425712B2BB658B9196932E02C78B2582FE742DAA28")),
            //     y=bytes2long(hexdec("32879423AB1A0375895786C4BB46E9565FDE0B5344766740AF268ADB32322E5C")),
            //     cofactor=4,
            //     e=0x01,
            //     d=bytes2long(hexdec("0605F6B7C183FA81578BC39CFAD518132B9DF62897009AF7E522C32D6DC7BFFB")),
            // ),
        } else if (curveId == id_tc26_gost_3410_12_256_paramSetB) {
            // "id-tc26-gost-3410-12-256-paramSetB": GOST3410Curve(
            //     p=bytes2long(hexdec("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97")),
            //     q=bytes2long(hexdec("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6C611070995AD10045841B09B761B893")),
            //     a=bytes2long(hexdec("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD94")),
            //     b=bytes2long(hexdec("00000000000000000000000000000000000000000000000000000000000000a6")),
            //     x=bytes2long(hexdec("0000000000000000000000000000000000000000000000000000000000000001")),
            //     y=bytes2long(hexdec("8D91E471E0989CDA27DF505A453F2B7635294F2DDF23E3B122ACC99C9E9F1E14")),
            // ),
        } else if (curveId == id_tc26_gost_3410_12_256_paramSetC) {
            // "id-tc26-gost-3410-12-256-paramSetC": GOST3410Curve(
            //     p=bytes2long(hexdec("8000000000000000000000000000000000000000000000000000000000000C99")),
            //     q=bytes2long(hexdec("800000000000000000000000000000015F700CFFF1A624E5E497161BCC8A198F")),
            //     a=bytes2long(hexdec("8000000000000000000000000000000000000000000000000000000000000C96")),
            //     b=bytes2long(hexdec("3E1AF419A269A5F866A7D3C25C3DF80AE979259373FF2B182F49D4CE7E1BBC8B")),
            //     x=bytes2long(hexdec("0000000000000000000000000000000000000000000000000000000000000001")),
            //     y=bytes2long(hexdec("3FA8124359F96680B83D1C3EB2C070E5C545C9858D03ECFB744BF8D717717EFC")),
            // ),
        } else if (curveId == id_tc26_gost_3410_12_256_paramSetD) {
            // "id-tc26-gost-3410-12-256-paramSetD": GOST3410Curve(
            //     p=bytes2long(hexdec("9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D759B")),
            //     q=bytes2long(hexdec("9B9F605F5A858107AB1EC85E6B41C8AA582CA3511EDDFB74F02F3A6598980BB9")),
            //     a=bytes2long(hexdec("9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D7598")),
            //     b=bytes2long(hexdec("000000000000000000000000000000000000000000000000000000000000805a")),
            //     x=bytes2long(hexdec("0000000000000000000000000000000000000000000000000000000000000000")),
            //     y=bytes2long(hexdec("41ECE55743711A8C3CBF3783CD08C0EE4D4DC440D4641A8F366E550DFDB3BB67")),
            // ),
        }
        require(false, "Unknown curve");
    }
}
