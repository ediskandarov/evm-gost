// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "solidity-BigNumber/BigNumbers.sol";
import "./BNModInverse.sol";

library CurveLib {
    using BNModInverse for BigNumber;
    using BigNumbers for BigNumber;

    event log(string);
    event logs(bytes);
    event log_uint(uint);

    struct Curve {
        BigNumber p; // Characteristic of the underlying prime field
        BigNumber q; // Elliptic curve subgroup order
        // Equation coefficients of the elliptic curve in canonical form
        BigNumber a;
        BigNumber b;
        // // Equation coefficients of the elliptic curve in twisted Edwards form
        // int e;
        // int d;
        // Basic point X and Y coordinates
        BigNumber x;
        BigNumber y;
        uint cofactor;
    }

    struct ExpVars {
        BigNumber p1x;
        BigNumber p1y;
        BigNumber p2x;
        BigNumber p2y;
    }

    function newCurve(
        uint p,
        uint q,
        uint a,
        uint b,
        uint x,
        uint y,
        // int e,
        // int d,
        uint cofactor
    ) internal view returns (Curve memory) {
        Curve memory curve = Curve({
            p: BigNumbers.init(p, false),
            q: BigNumbers.init(q, false),
            a: BigNumbers.init(a, false),
            b: BigNumbers.init(b, false),
            // e: e,
            // d: d,
            x: BigNumbers.init(x, false),
            y: BigNumbers.init(y, false),
            cofactor: cofactor
        });

        require(contains(curve, curve.x, curve.y), "Invalid curve parameters");

        return curve;
    }

    function contains(
        Curve memory curve,
        BigNumber memory x,
        BigNumber memory y
    ) internal view returns (bool) {
        BigNumber memory r1 = y.modmul(y, curve.p); // y * y % p
        BigNumber memory r2 = x.mul(x).add(curve.a).mul(x).add(curve.b).mod(
            curve.p
        ); // ((x * x + curve.a) * x + curve.b) % curve.p
        return r1.eq(pos(curve, r2));
    }

    /**
     * Make positive number
     */
    function pos(
        Curve memory curve,
        BigNumber memory v
    ) internal pure returns (BigNumber memory) {
        if (v.lt(BigNumbers.zero())) {
            return v.add(curve.p);
        } else {
            return v;
        }
    }

    function _add(
        Curve memory curve,
        ExpVars memory vars
    ) internal view returns (BigNumber memory, BigNumber memory) {
        BigNumber memory t;
        BigNumber memory tx_;
        BigNumber memory ty;
        if (vars.p1x.eq(vars.p2x) && vars.p1y.eq(vars.p2y)) {
            {
                BigNumber memory three = BigNumbers.init(3, false);
                BigNumber memory two = BigNumbers.two();
                // double
                t = (three.mul(vars.p1x).mul(vars.p1x).add(curve.a)).modmul(
                    (two.mul(vars.p1y).modinv256(curve.p)),
                    curve.p
                );
            }
        } else {
            tx_ = pos(curve, vars.p2x.sub(vars.p1x)).mod(curve.p);
            ty = pos(curve, vars.p2y.sub(vars.p1y)).mod(curve.p);
            t = ty.modmul(tx_.modinv256(curve.p), curve.p);
        }
        tx_ = pos(curve, t.mul(t).sub(vars.p1x).sub(vars.p2x)).mod(curve.p);
        ty = pos(curve, t.mul((vars.p1x.sub(tx_))).sub(vars.p1y)).mod(curve.p);
        return (tx_, ty);
    }

    function exp(
        Curve memory curve,
        uint degree
    ) internal returns (BigNumber memory, BigNumber memory) {
        return exp(curve, degree, curve.x, curve.y);
    }

    function exp(
        Curve memory curve,
        uint degree,
        BigNumber memory x,
        BigNumber memory y
    ) internal returns (BigNumber memory, BigNumber memory) {
        BigNumber memory tx_ = x;
        BigNumber memory ty = y;

        require(degree != 0, "Bad degree value");

        emit log("exp operation");

        while (degree != 0) {
            emit log("add iteration");
            if (degree & 1 == 1) {
                (tx_, ty) = _add(
                    curve,
                    ExpVars({p1x: tx_, p1y: ty, p2x: x, p2y: y})
                );
            }
            degree = degree >> 1;
            (x, y) = _add(curve, ExpVars({p1x: x, p1y: y, p2x: x, p2y: y}));
        }
        return (tx_, ty);
    }

    /**
     * Verify provided digest with the signature
     *
     * @param {Curve} curve - curve to use
     * @param {uint} pubX - x component of public key
     * @param {uint} pubY - y component of public key
     * @param {bytes32} digest - digest needed to check
     * @param {64 bytes} signature - signature to verify with
     * @return {bool}
     */
    function verify(
        Curve memory curve,
        uint pubX,
        uint pubY,
        bytes memory digest,
        bytes memory signature
    ) internal returns (bool) {
        require(signature.length == 64, "Invalid signature length");

        BigNumber memory q = curve.q;
        BigNumber memory p = curve.p;

        (BigNumber memory r, BigNumber memory s) = parseSignature(signature);

        BigNumber memory zero = BigNumbers.zero();
        if (r.lte(zero) || r.gte(q) || s.lte(zero) || s.gte(q)) {
            return false;
        }
        BigNumber memory e = BigNumbers.init(digest, false).mod(curve.q);
        if (e.eq(zero)) {
            e = BigNumbers.one();
        }

        BigNumber memory v = e.modinv256(q);
        BigNumber memory z1 = s.modmul(v, q);
        BigNumber memory z2 = q.sub(r.modmul(v, q));
        (BigNumber memory p1x, BigNumber memory p1y) = exp(
            curve,
            z1.toUint256()
        );
        (BigNumber memory q1x, BigNumber memory q1y) = exp(
            curve,
            z2.toUint256(),
            BigNumbers.init(pubX, false),
            BigNumbers.init(pubY, false)
        );
        BigNumber memory lm = q1x.sub(p1x);
        if (lm.lt(zero)) {
            lm = lm.add(p);
        }
        lm = lm.modinv256(p);
        z1 = q1y.sub(p1y);
        lm = lm.modmul(z1, p);
        lm = lm.modmul(lm, p);
        lm = lm.sub(p1x).sub(q1x);
        lm = lm.mod(p);
        if (lm.lt(zero)) {
            lm = lm.add(p);
        }
        lm = lm.mod(q);

        return lm.eq(r);
    }

    function parseSignature(
        bytes memory signature
    ) internal view returns (BigNumber memory, BigNumber memory) {
        uint r;
        uint s;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
        }

        return (BigNumbers.init(r, false), BigNumbers.init(s, false));
    }
}
