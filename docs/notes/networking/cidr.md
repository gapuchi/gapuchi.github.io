# Classless Inter-Domain Routing (CIDR)

CIDR
: Method for IP routing and for allocating IP addresses

**Notation**: `<IP Address>/<Decimal Number>`

The decimal number is the number of leading bits that represent the network mask - aka the prefix for an IP address.

This is all in terms of IPv4.

An IP has 32 bits.


> Ex: `10.0.0.0/16`
>
> The IP address can be represented as : `00001010 00000000 0000000 0000000`
>
> The subnet mask is `11111111 11111111 00000000 0000000` or `255.255.0.0`
> 
> This means there are 16 bits available for the block, or a range of 2^16 addresses.

### If we have 16 bits available, and we want X subnets, what is the range for each one?

If we have 8, then each one would have $\frac{2^{16}}{8} = \frac{2^{16}}{2^3} = 2^{13}$ addresses, or 13 bits each. A block would have a 19 bit mask:

1. `00001010 00000000 00000000 0000000` or `10.0.0.0/19`
1. `00001010 00000000 00100000 0000000` or `10.0.32.0/19`
1. `00001010 00000000 01000000 0000000` or `10.0.64.0/19`
1. `00001010 00000000 01100000 0000000` or `10.0.96.0/19`
1. `00001010 00000000 10000000 0000000` or `10.0.128.0/19`
1. `00001010 00000000 10100000 0000000` or `10.0.160.0/19`
1. `00001010 00000000 11000000 0000000` or `10.0.192.0/19`
1. `00001010 00000000 11100000 0000000` or `10.0.224.0/19`

If we have $X$ subnets, then each one would have:

$$
\begin{align*}
\frac{2^{16}}{X} &= \frac{2^{16}}{2^{log_2(X)}} \\
&= 2^{16 - log_2(X)}
\end{align*}
$$

Or $16 - log_2(X)$ bits each. A block would have $16 + log_2(X)$ bit mask. Since the bit mask may not be an integer due to the log, we need to take the ceiling of the log. This is to ensure there are enough "groups" of blocks for X.

TLDR: Each subnet has $16 - Y$ bits, where $2^Y \geq X > 2^{Y-1}$