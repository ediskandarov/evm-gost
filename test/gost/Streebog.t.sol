// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost/Streebog.sol";

contract StreebogTest is Test {
    Streebog streebog;

    function setUp() public {
        streebog = new Streebog();
    }

    // keep cased in separate functions to track gas usage
    function test_hash256_case1() external {
        assertEq(
            streebog.hash256(bytes("hello world")),
            hex"c600fd9dd049cf8abd2f5b32e840d2cb0e41ea44de1c155dcd88dc84fe58a855"
        );
    }

    // Examples from adegtyarev streebog implementation
    // @see https://github.com/adegtyarev/streebog/tree/master/examples
    function test_hash256_m1_std() external {
        assertEq(
            streebog.hash256(
                bytes(
                    "012345678901234567890123456789012345678901234567890123456789012"
                )
            ),
            hex"9d151eefd8590b89daa6ba6cb74af9275dd051026bb149a452fd84e5e57b5500"
        );
    }

    function test_hash256_m2_std() external {
        assertEq(
            streebog.hash256(
                // M2 = "Се ветри, Стрибожи внуци, веютъ с моря стрелами на храбрыя плъкы Игоревы"
                // in CP1251 encoding. Below hexlified version of it.
                bytes(
                    hex"d1e520e2e5f2f0e82c20d1f2f0e8e1eee6e820e2edf3f6e82c20e2e5fef2fa20"
                    hex"f120eceef0ff20f1f2f0e5ebe0ece820ede020f5f0e0e1f0fbff20efebfaeafb"
                    hex"20c8e3eef0e5e2fb"
                )
            ),
            hex"9dd2fe4e90409e5da87f53976d7405b0c0cac628fc669a741d50063c557e8f50"
        );
    }

    function test_hash256_m3_empty_message() external {
        assertEq(
            streebog.hash256(bytes("")),
            hex"3f539a213e97c802cc229d474c6aa32a825a360b2a933a949fd925208d9ce1bb"
        );
    }

    function test_hash256_m4_zero_message() external {
        assertEq(
            streebog.hash256(
                bytes(
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                )
            ),
            hex"df1fda9ce83191390537358031db2ecaa6aa54cd0eda241dc107105e13636b95"
        );
    }

    function test_hash256_63_byte_zero_message() external {
        assertEq(
            streebog.hash256(
                bytes(
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                    hex"00000000000000000000000000000000000000000000000000000000000000"
                )
            ),
            hex"4efe4b89530a0fc90f8c440296ec19ac987b61e8e4e9870d06274a1408237333"
        );
    }

    function test_hash256_127_byte_zero_message() external {
        assertEq(
            streebog.hash256(
                bytes(
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                    hex"00000000000000000000000000000000000000000000000000000000000000"
                )
            ),
            hex"f8882403f168c8b83375c595d7634fa8fc36aa4776768d311923763347b5e6e3"
        );
    }

    function test_hash256_128_byte_zero_message() external {
        assertEq(
            streebog.hash256(
                bytes(
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                    hex"0000000000000000000000000000000000000000000000000000000000000000"
                )
            ),
            hex"ac7bea5c0531780228e97f6a033e5f801a02c903d857252cd721a21edfaafeb1"
        );
    }
}
