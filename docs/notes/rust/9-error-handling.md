---
layout: post
title: Error Handling
part: 9
---

# Error Handling

In many occasions, Rust requires you to acknowledge the possibility of an error and take some action before your code will compile.

Rust groups errors into 2 main categories:

1. recoverable - errors you can report to the user and retry the operation
1. unrecoverable - usually bugs. (e.g. index out of bounds)

Rust doesn't have exceptions. It has the type `Result<T, E>` for recoverable errors and the `panic!` macro that stops execution when the program encounters an unrecoverable error.

## Unrecoverable Errors with `panic!`

When the `panic!` macro executes, your program will print a failure message, unwind and clean up the stack, and then quit.

> By default, when a panic occurs, the programs starts *unwinding* - Rust walks back up the stack and cleans up the data from each funciton it encounters. 
> This is a a lot of work. An alternative is to immediately *abort* - which ends the program without cleaning it up. The memory that the program uses will need to be cleaned up by the operating system. If you need the binary to be as small as possible, you can switch from unwinding to aborting upon a panic by adding `panic = 'abort'` to the apporiate `[profile]` sections.
> ```toml
> [profile.release]
> panic = 'abort'
> ```

An example of `panic!`

```rust
fn main() {
    panic!("crash and burn");
}
```

The error message will print the location of the `panic`.

```console
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.25s
     Running `target/debug/panic`
thread 'main' panicked at 'crash and burn', src/main.rs:2:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.
```

### Using a `panic!` Backtrace

Let's take a look at an example where we do not throw the `panic`.

```rust
fn main() {
    let v = vec![1, 2, 3];

    v[99];
}
```

This is essentially an index out of bounds exception in Java.

```console
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.27s
     Running `target/debug/panic`
thread 'main' panicked at 'index out of bounds: the len is 3 but the index is 99', /rustc/5e1a799842ba6ed4a57e91f7ab9435947482f7d8/src/libcore/slice/mod.rs:2806:10
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.
```

The location in the error message points to a file that we don't own. This is because the implementation of the vector is throwing the panic.

How do we get the stacktrace (or backtrace)? The last line tells us.

A **backtrace** is a list of all the functions that hav ebeen caleed to get to this point.

If we set the environment variable, we can view this:

```console
thread 'main' panicked at 'index out of bounds: the len is 3 but the index is 99', main.rs:4:5
stack backtrace:
   0: _rust_begin_unwind
   1: core::panicking::panic_fmt
   2: core::panicking::panic_bounds_check
   3: <usize as core::slice::SliceIndex<[T]>>::index
   4: core::slice::<impl core::ops::index::Index<I> for [T]>::index
   5: <alloc::vec::Vec<T> as core::ops::index::Index<I>>::index
   6: main::main
   7: core::ops::function::FnOnce::call_once
note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.
```

## Recoverable Errors with `Result`

All errors do not need a program to stop completely.

`Result` is an enum is defined as having two variants:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

`T` and `E` are generics, representing the type for a success and error, respectively.

An example of a function that results in a possible failure.

```rust
use std::fs::File;

fn main() {
    let f = File::open("hello.txt");
}
```

We know this returns a `Result` by looking at the [the API documentation](https://doc.rust-lang.org/std/fs/struct.File.html#method.open) or asking the compiler.

Looking at the API we know that `File::open` returns `std::io::Result<std::fs::File>`. Not what we expect? If we look at [the defintion](https://doc.rust-lang.org/std/io/type.Result.html) of `std::io::Result`, we learn that is is the same as `std::result::Result<std::fs::File, std::io::Error>`.

So if `File::open` succeeds, the result will have `File`, else `Error`.

We can then handle each case:

```rust
use std::fs::File;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => panic!("Problem opening the file: {:?}", error),
    };
}
```

> Note that, like the `Option` enum, the `Result` enum and its variants have been brought into scope by the prelude, so we don’t need to specify `Result::` before the `Ok` and `Err` variants in the match arms.

### Matching on Different Errors

We may not want to `panic!` for every failure. Let's say we want to create a file if the file doesn't exist and `panic!` for other cases, like permission issue.

```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("Problem creating the file: {:?}", e),
            },
            other_error => {
                panic!("Problem opening the file: {:?}", other_error)
            }
        },
    };
}
```

`std::io::Error` has a [kind](https://doc.rust-lang.org/std/io/struct.Error.html#method.kind) method, which returns `ErrorKind`, an enum containing variants representing the different kinds of errors that might result from an `io` operation.

The above matches on `NotFound`, meaning we didn't find the file.

That is a lot of `match` - we'll learn about closures that will allow us to make this more concise:

```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt").unwrap_or_else(|error| {
        if error.kind() == ErrorKind::NotFound {
            File::create("hello.txt").unwrap_or_else(|error| {
                panic!("Problem creating the file: {:?}", error);
            })
        } else {
            panic!("Problem opening the file: {:?}", error);
        }
    });
}
```

(This may not make complete sense until we get to closures.) `unwrap_or_else` and other methods will help us get rid of nested `match` expressions when handling errors.

### Shortcuts for Pan on Error: `unwrap` and `expect`

`match` is fine and dandy, but it gets verbose. There are helper methods to define varios tasks.

`unwrap` is a shortcut method that is implemented just like the `match` above. It will return the value inside `Ok` or `panic!` for `Err`:

```rust
use std::fs::File;

fn main() {
    let f = File::open("hello.txt").unwrap();
}
```

If we run this with a `hello.txt` file:

```console
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Os { code: 2, kind: NotFound, message: "No such file or directory" }', main.rs:4:37
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

`expect` is similar to `unwrap`, but it also let's us choose the `panic!` error message:

```rust
use std::fs::File;

fn main() {
    let f = File::open("hello.txt").expect("Failed to open hello.txt");
}
```

The error we see on running:

```console
thread 'main' panicked at 'Failed to open hello.txt: Os { code: 2, kind: NotFound, message: "No such file or directory" }', main.rs:4:37
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

This allows us to give meaningful error messages.

### Propagating Errors

Sometimes, you want to handle the error outside of the function. This gives the callers of the function more control.


```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}
```

(This method can be done in a shorter way, we'll get to that.)

This method will return the file string on success, but an error if it fails in either opening the file or reading the file. Both errors are covered by the return type.

We propagate the errors because we do not know the context of reading a file. Do people want a default string if the reading failed? Do we want to `panic!`? Who knows. We let the callers of the function decide this.

The concept of *propagating* is so common that Rust provides the `?` operator to make it easier.

### A Shortcut for Propagating Erros: the `?` Operator

Below is the same implementation as our previous example:

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```

What placing `?` after `Result` does:

- If the value of `Result` is an `Ok`, the value inside `Ok` will get returned from this expression.
- If the value of `Result` is an `Err`, the `Err` will be returned from the whole function as if we can used the `return` keyword.

**One main difference** from using `?` and the previous `match` expressions - the errors that have `?` called on them go through the `from` function defined in the`From` trait, which converts errors from one type into another.

The returned error type is converted to the error type defined in the return type of the current function. This is useful when a function returns one error type to represent all the ways a function can fail, even if specific parts fails for different reasons. As long as the error types define the `from` function to convert itself to the returned error type, the `?` operator handles that conversion.

This helps us get rid of a lot of boilerplate code. We can simplify it even more by chaining:

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut s = String::new();
    File::open("hello.txt")?.read_to_string(&mut s)?;
    Ok(s)
}
```

This example is fairly common, so Rust provides an even more convenient way to implement this:

```rust
use std::fs;
use std::io;

fn read_username_from_file() -> Result<String, io::Error> {
    fs::read_to_string("hello.txt")
}
```

Rust provides a `fs::read_to_string` function that creates a new `String`, read the contents of a file, puts it into the `String`, and returns it. (This didn't give us the chance of explaining the error handling obviously so we didn't go with this as our working example.)

### The `?` Operator Can Be Used in Functions That Return `Result`

The `?` operator can be used in functions that have a return type of `Result`. This is because the `?` operator works in the same way as the `match` expression - specifically `return Err(e)` logic. Therefore, the function using `?` must define `Err` as a return type to be compatible.

Because of this, the following will fail:

```rust
use std::fs::File;

fn main() {
    let f = File::open("hello.txt")?;
}
```

with an error message containing:

```console
the `?` operator can only be used in an async function that returns `Result` or `Option` (or another type that implements `std::ops::Try`)
```

If you encounter this error, you either need to change the return type of the function or handle the `Result` in another way.

The `main` method is special and has restrictions on what the return type must be. One return type that is valid is `()` and another is `Result<T,E>`:

```rust
use std::error::Error;
use std::fs::File;

fn main() -> Result<(), Box<dyn Error>> {
    let f = File::open("hello.txt")?;

    Ok(())
}
```

The `Box<dyn Error>` type is called a trait object. We'll talk more about that later. Basically it just means "any kind of error".

## To `panic!` or Not To `panic!`

If you call `panic!`, you're making the decision on behalf of the code calling your code that a situation is unrecoverable, regardless of context. If you choose to return `Result`, you are giving the calling code options rather than making the decision for them. They can choose to `panic!` themselves, or handle the `Err`, or to propagate the `Err`. Any case, it provides flexibility. Returning `Result` is a good default choice.

There are rare situations where `panic!` is more appropriate.

(To Be Continued)
