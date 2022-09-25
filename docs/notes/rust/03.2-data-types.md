# Data Types

Rust is **statically typed**, which means it knows all the types at compile time. The compiler can infer (usually) what type a variable is, but there are cases where it cannot.

An example is parsing a string:

```rust
let guess: u32 = "42".parse().expect("Not a number!");
```

Without the declared type, compiler will throw an error.

## Scalar Types

**Scalar types** represent a single value. Rust has four primary scalar types:

1. integer
1. floating point numbers
1. boolean
1. characters

## Compound Types

**Compound types** can group multiple values into one type. Rust has two primary compound types:

1. Tuple
1. Array
