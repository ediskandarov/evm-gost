## References

- [RFC 4357](https://datatracker.ietf.org/doc/html/rfc4357) - Additional Cryptographic Algorithms for Use with GOST 28147-89, GOST R 34.10-94, GOST R 34.10-2001, and GOST R 34.11-94 Algorithms
- [RFC 7836](https://datatracker.ietf.org/doc/html/rfc7836) - Guidelines on the Cryptographic Algorithms to Accompany the Usage of Standards GOST R 34.10-2012 and GOST R 34.11-2012

## Up to date certificate

### Certificate inspection with OpenSSL (GOST engine)

We can find public key value using openssl command

```console
$ openssl x509 -in 1.cer -text -noout

...
Public Key Algorithm: GOST R 34.10-2012 with 256 bit modulus
    Public key:
        X:EE25D54D66E573A9DBFCB76192EEDF4ABC59D99F8B8DBB345C2D55F0D8D74D36
        Y:8191865C323A156FD27EC712C2BE89A15937C8C50BC428AC9BC2B878979F1EA4
    Parameter set: id-GostR3410-2001-CryptoPro-XchA-ParamSet
...
```

We can get public key from certificate using this technique.

1. Extract public key from certificate into PEM encoded file.
2. Parse public key file with `asn1parse` tool to get raw public key.

```console
$ openssl x509 -in 1.cer -noout -pubkey > pubkey1.pem
$ openssl asn1parse -in pubkey1.pem -strparse 35
    0:d=0  hl=2 l=  64 prim: OCTET STRING      [HEX DUMP]:364DD7D8F0552D5C34BB8D8B9FD959BC4ADFEE9261B7FCDBA973E5664DD525EEA41E9F9778B8C29BAC28C40BC5C83759A189BEC212C77ED26F153A325C869181
```

`X` and `Y` coordinates are HEX encoded string.

## Certificate inspection with Windows tools

Windows displays public key as the following:

```
04 40 36 4d d7 d8 f0 55 2d 5c 34 bb 8d 8b 9f d9 59 bc 4a df ee 92 61 b7 fc db a9 73 e5 66 4d d5 25 ee a4 1e 9f 97 78 b8 c2 9b ac 28 c4 0b c5 c8 37 59 a1 89 be c2 12 c7 7e d2 6f 15 3a 32 5c 86 91 81
```

Notes

- `04 40` - unknown sequence of bytes
- `36 4d d7 d8 f0 55 2d 5c 34 bb 8d 8b 9f d9 59 bc 4a df ee 92 61 b7 fc db a9 73 e5 66 4d d5 25 ee` - X coordinate of public key(reverse byte order)
- `a4 1e 9f 97 78 b8 c2 9b ac 28 c4 0b c5 c8 37 59 a1 89 be c2 12 c7 7e d2 6f 15 3a 32 5c 86 91 81` - Y coordinate of public key(reverse byte order)

Public key parameters set:

```
30 13 06 07 2a 85 03 02 02 24 00 06 08 2a 85 03 07 01 01 02 02
```

Notes

- `30 13` - unknown sequence of bytes
- `06 07 2a 85 03 02 02 24 00` - id-GostR3410-2001-CryptoPro-XchA-ParamSet
- `06 08 2a 85 03 07 01 01 02 02` - id-tc26-gost3411-12-256
