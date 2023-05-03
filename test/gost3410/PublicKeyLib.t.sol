// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/gost3410/PublicKeyLib.sol";

contract PublicKeyLibTest is Test {
    using PublicKeyLib for PublicKeyLib.PublicKey;

    function test_newPublicKey() external {
        PublicKeyLib.PublicKey memory pubKey;

        bytes memory pubKeyRaw = bytes(
            hex"364dd7d8f0552d5c34bb8d8b9fd959bc4adfee9261b7fcdba973e5664dd525ee"
            hex"a41e9f9778b8c29bac28c40bc5c83759a189bec212c77ed26f153a325c869181"
        );
        pubKey.init(PublicKeyLib.Mode.Mode2001, pubKeyRaw);

        assertEq(
            bytes32(uint(pubKey.X)),
            bytes32(
                0xee25d54d66e573a9dbfcb76192eedf4abc59d99f8b8dbb345c2d55f0d8d74d36
            )
        );
        assertEq(
            bytes32(uint(pubKey.Y)),
            bytes32(
                0x8191865C323A156FD27EC712C2BE89A15937C8C50BC428AC9BC2B878979F1EA4
            )
        );
    }
}
