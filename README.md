# evm-gost

GOST 34.11 and GOST 34.10 algorithms for cryptography with Solidity.

## GOST 34.11-2012 hashing algorithm

GOST 34.11-2012(aka Streebog) hashing algorithm implementation in Solidity.

### Credits

The library is based on [Alexey Degtyarev](https://github.com/adegtyarev)
[streebog](https://github.com/adegtyarev/streebog) implementation.

### Testing

Install [Foundry](https://getfoundry.sh/) toolkit for Ethereum application development.

Run tests

```console
$ forge test
```

### Gas usage analysis

The algorithm uses approximately 1 300 000 gas to calculate hash on `hello world` message.

Message `hello world` ~ 1_300_000 gas.

Message `012345678901234567890123456789012345678901234567890123456789012` ~ 1_300_000 gas.

Message `Се ветри, Стрибожи внуци, веютъ с моря стрелами на храбрыя плъкы Игоревы` ~ 1_700_000 gas.

Empty message ~ 1_300_000 gas.

Message with 63 bytes of `0x00` ~ 1_300_000 gas.

Message with 127 bytes of `0x00` ~ 1_700_000 gas.

Message with 128 bytes of `0x00` ~ 2_100_000 gas.

What means, gas consumption is the following: 63 bytes(or less) message - 1_300_000 gas.
Each additional 64 bytes of the message adds 400_000 gas usage on top.

## GOST 34.10 verification of digital signature

### Gas usage analysis

Crucial part of digital signature verification is elliptic curve point multiplication.

It requires calculation of a modular multiplicative inverse.

One modular modular multiplicative inverse operation consumes ~ 150_000 gas.

In order to verify digital signature, we need to go through approximately $2 * 256 = 512$ mod inverse operations.

What results in 75M gas consumption. This has no practical sense.
