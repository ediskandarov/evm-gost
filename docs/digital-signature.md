## GOST 34.10-2022

### Signing algorithm

Signature is $(r,s)$.

$k$ - a cryptographically secure random integer.

$d$ - a private key.

$Q$ - a public key.

$h$ - a message hash being signed.

$P_{x,y}$ - an elliptic curve base point.

$R = k * P$

$r = P_{x}$

$s = r * d + h * k$

### Signature verification

Multiply by basis point $P$.

$s * P = r * d * P + h * k * P = r * Q + h * R$

In that equation $R$ is unknown.

$h * R = s * P - r * Q$

$R = (s * P - r * Q) / h$

And compare $R_{x}$ coordinate with $r$

Algorithm analysis. In order to calculate $R$ we need to do elliptic curve point multiplications: $s * P$ and $r * Q$.

## ECDSA

### Signing algorithm

$k$ - a cryptographically secure random integer.

$G$ - elliptic curve base point.

$(x_1, y_1) = k * G$

$r = x_1$

$z$ - a message hash being signed.

$s = k^{-1} * (z + r* d)$

### Verification algorithm

Calculate $u_1 = z * s^{-1}$; $u_2 = r * s^{-1}$

Calculate curve point $(x_1, y_1) = u_1 * G + u_2 * Q$

$r \equiv x_1$

Algorithm analysis. In order to calculate $R$ we need to do elliptic curve point multiplications: $u_1 * G$ and $u_2 * Q$.

### Solidity

Solidity has a built in `ecrecover` opcode that [recovers public key](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm#Public_key_recovery) from ECDSA signature. It costs 3000 gas.
