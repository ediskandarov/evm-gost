// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost/Streebog.sol";

contract StreebogTest is Test {
    Streebog streebog;

    function setUp() public {
        streebog = new Streebog();
    }

    function test_hash256() external {
        bytes memory hash256 = streebog.hash256(bytes("hello world"));

        assertEq(hash256,
            hex"c600fd9dd049cf8abd2f5b32e840d2cb0e41ea44de1c155dcd88dc84fe58a855"
        );
    }
}
