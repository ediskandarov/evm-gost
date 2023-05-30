// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./CurveLib.sol";

library PublicKeyLib {
    enum Mode {
        Mode2001,
        Mode2012
    }

    struct PublicKey {
        CurveLib.Curve curve;
        Mode mode;
        int x;
        int y;
    }

    function init(
        PublicKey memory pubKey,
        Mode mode,
        bytes memory raw
    ) internal pure {
        require(mode == Mode.Mode2001, "Only 2001 mode is supported");

        bytes memory rawRev = new bytes(64);

        require(raw.length == rawRev.length, "Invalid public key length");

        for (uint i = 0; i < rawRev.length; i++) {
            rawRev[i] = raw[raw.length - i - 1];
        }

        int X;
        int Y;
        assembly {
            X := mload(add(rawRev, 64))
            Y := mload(add(rawRev, 32))
        }
        (pubKey.x, pubKey.y) = (X, Y);
        pubKey.mode = mode;
        // pubKey.curve = ;
    }
}
