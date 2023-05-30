## Useful links

- [Optimized Binary GCD for Modular Inversion](https://eprint.iacr.org/2020/972.pdf)
- [Greatest common divisor algorithms](https://cacr.uwaterloo.ca/hac/about/chap14.pdf#page=17)
- [Python program implementing the extended binary GCD algorithm](https://www.ucl.ac.uk/~ucahcjm/combopt/ext_gcd_python_programs.pdf)
- [What is modular arithmetic?](https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/what-is-modular-arithmetic)
- [Overflow-safe modular addition and subtraction in C?](https://stackoverflow.com/questions/11248012/overflow-safe-modular-addition-and-subtraction-in-c)
- [Matters Computational](https://www.jjj.de/fxt/#fxtbook)

## Optimizations

### Number is even check

To test if a number is even we check reminder of division by 2.

```python
if (x % 2) == 0:
    print('is even')
else:
    print('is odd')
```

This operation could also been written as the following:

```python
if (x & 1) == 0:
    print('is even')
else:
    print('is odd')
```

This optimization in Solidity gave ~50000 gas(200_000 to 150_000) for modular inverse function.
