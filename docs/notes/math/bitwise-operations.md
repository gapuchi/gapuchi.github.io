# Bitwise Operations Tips/Tricks

### How do you negate a number, ignoring leading zeroes?

Let's say you have unsigned, 8 bit integer: `5`. How can we get the inverse of this? (`~5`)

`5` in binary is `101`, so the inverse would be `010` or `2`.

If we were to do the bitwise operation inverse, we would get something different. Since it is a 8 bit integer, `5` is actually `00000101` and the inverse would be `11111010`.

So how do we do this? `~5 & ((1 << 3) - 1)`

We take `1`, shift it over by however many digits we want to inverse and subtract 1. This gives us leadings zeroes with a specific number of tailing ones. We then intersect this with the inverse. This essentially get's rid of the leading ones that result from the inverse.