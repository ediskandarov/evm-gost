# GOST 34.11-2012 hashing algorithm Solidity implementation

Warning. Not useful for production.

## Testing

Install [Foundry](https://getfoundry.sh/) toolkit for Ethereum application development.

Run tests

```console
$ forge test
```

## Gas usage analysis

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
