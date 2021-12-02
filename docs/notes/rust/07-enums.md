---
layout: post
title: Enums and Pattern Matching
part: 7
---

# Enums and Pattern Matching

## Defining an Enum

```rust
enum IpAddrKind {
    V4,
    V6,
}
```

### Enum Values

We can create instances like this:

```rust
let four = IpAddrKind::V4;
let six = IpAddrKind::V6;
```

We can store additional data inside enums:

```rust
enum IpAddr {
    V4(String),
    V6(String),
}

let home = IpAddr::V4(String::from("127.0.0.1"));

let loopback = IpAddr::V6(String::from("::1"));
```

One cool advantage, each instance can have different types of data associated with it:

```rust
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);

let loopback = IpAddr::V6(String::from("::1"));
```

There is a [standard library](https://doc.rust-lang.org/std/net/enum.IpAddr.html) for this!

---

Another example of an enum with a wide variety of types in its variants:

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}
```

* `Quit` has no data associated with it at all
* `Move` has a struct associated with it
* `Write` has a string.
* `ChangeColor` has 3 `i32`.

**You can** just create structs for the variants above, but they wouldn't be grouped together:

```rust
struct QuitMessage;
struct MoveMessage {
    x: i32,
    y: i32,
}
struct WriteMessage(String);
struct ChangeColorMessage(i32, i32, i32);
```

**but** it's more annoying to create a function that takes these 4 types. With an enum, its a single type, `Message`.

**Another similarity** - we can define methods on enums using `impl`.

```rust
impl Message {
    fn call(&self) {
        //method
    }
}

let m = Message::Write(String::from("hello"))
m.call()
```

### The `Option` Enum and Its Advantage Over Null Values

Basically, the argument for `Option` in Scala. Rust has defined its own [Option](https://doc.rust-lang.org/std/option/enum.Option.html):

```rust
enum Option<T> {
    Some(T),
    None,
}
```

`Option<T>` is an enum, and `Some(T)` and `None` are variants of the enum. (`<T>` is the syntax for generics. Later chapter.)

## The `match` Control Flow Operator

Basically the `match` in Scala.

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}
```

### Pattern that Bind to Value

We can extract values using `match`, kinda like how we can extract values from `case class`es in Scala.

Let's say we have

```rust
enum UsState {
    Alabama,
    Alaska,
    // --snip--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}
```

We can extract the `UsState`:

```rust
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        }
    }
}
```

### Matching with `Option<T>`

```rust
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        None => None,
        Some(i) => Some(i + 1),
    }
}

let five = Some(5);
let six = plus_one(five);
let none = plus_one(None);
```

### Matches Are Exhaustive

**Unlike Scala**, matches in Rust **has to be exhaustive**. There will be a compile error if it isn't:

```rust
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        Some(i) => Some(i + 1),
    }
} //Won't compile
```

### The `_` Placeholder

Similar to Scala, `_` can be used as a catch all:

```rust
let some_u8_value = 0u8;
match some_u8_value {
    1 => println!("one"),
    3 => println!("three"),
    5 => println!("five"),
    7 => println!("seven"),
    _ => (),
}
```

## Concise Control Flow with `if let`

Rust combines `if` and `let` to allow a more concise way to handle values that match one pattern while ignoring the rest.

For example, this is pretty wordy:

```rust
let some_value = Some(u08);
match some_value {
    case Some(3) => println!("triple"),
    _ => (),
}
```

We only care for `Some(3)`. We can use `if let`:

```rust
if let Some(3) = some_value {
    println!("triple");
}
```

`if let` takes a pattern and an expression separated by an `=`.

You can use `else` in addition:

```rust
let mut count = 0;
if let Coin::Quarter(state) = coin {
    println!("State quarter from {:?}!", state);
} else {
    count += 1;
}
```
