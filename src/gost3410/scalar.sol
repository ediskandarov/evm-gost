// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./intModInverse.sol";

library scalar {
    uint256 constant SECP256K1_N =
        0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141;

    function scalar_mul(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulmod(x, y, SECP256K1_N);
    }

    function scalar_inverse(uint256 x) internal pure returns (uint256) {
        uint256 r = uintModInverse.modinv(x, SECP256K1_N);
        return r;
    }
}
