# Functional Features

## Closures

Closures
: Anonymous functions that can be saved in a variable or passed into functions.

Closures, unlike functions, can capture values from the scope in which they're defined.

```rust
let x = |param1, param2| { 
    println!("{}", param2);
    param1
};
```

### Closure Type Inference and Annotation

> Why isn't there type annotations in the closure above?

Functions need type annotations on the parameters and the return values because they're part of an explicit interfaced exposed to your users. Rigidly defining the interface is important.

Closures are not used in the exposed interface. They are stored in variables and used without naming them. They are relevant only in a small scope. The compiler is able to infer the type of the parameters and return value, just like it can infer most variables.

We can type annotations if we want, but for the most part, they are redundant and not needed.

**Closures will have one concrete type inferred for each of their parameter and return value.**

This won't work:

```rust
fn main() {
    let example_closure = |x| x;

    let s = example_closure(String::from("hello"));
    let n = example_closure(5);
}
```

because the closure was inferred to have type String from the first instance, and it fails when it encounters the second.

### Storing Closures Using Generic Parameters and the `Fn` Trait

In order to store a closure in a struct, we need to define the type. This is because struct requires to know the types of all its fields.

**Each closure has its own, unique anonymous type.** Even if two closures have the same signature, they are still considered to have different types. **So in order to use closures in functions, structs, or anywhere we need to define the type, we use generics and trait bounds.**

All closures implement one the following traits: `Fn`, `FnMut`, or `FnOnce`.

We can add types to these trait bounds to represent the types of the parameters and return value.

So for a closure that has a parameter type of `u32` and return type `u32`, the type for the closure would be `Fn(u32) -> u32`.

Functions can also implement these traits too. We can pass in functions in places that require these traits.

### Capturing the Environment with Closures

Closures can do something functions can't - capture the environment and access variables from the scope in which they're defined.

```rust
fn main() {
    let x = 4;

    let equal_to_x = |z| z == x;

    let y = 4;

    assert!(equal_to_x(y));
}
```

We can't do the above with functions.

A closure uses memory to store these variables for use in the closure body. Functions will never incur this overhead because they can't capture the environment.

Closures can capture their environment, which maps to one of the traits it can implement:

1. `FnOnce` - Taking ownership - This method consumes variables it captures from the enclosing scope (the closure's environment). It needs to take the ownership of the variables and move them into the closure in order to consume them. It has `Once` in the name because the closure cannot take the ownership more than once for a variable, so it can only be called once.
1. `FnMut` - Borrows mutably.
1. `Fn` - Borrows immutably.

Rust infers the trait a closure implements based on how variables from the environment are being used.

All closures implement `FnOnce` since they can be called at least once.
Closures that do not move the captured variable implement the `FnMut` trait. Closures that do not need mutable access also implement the `Fn` trait.

You can force a closure to take ownership by using the `move` keyword before the param list.

With move:

```rust
fn main() {
    let x = vec![1, 2, 3];

    let equal_to_x = move |z| z == x;

    println!("can't use x here: {:?}", x);

    let y = vec![1, 2, 3];

    assert!(equal_to_x(y));
}
```

`x` is now moved into the closure. The `println!` after will fail because x moved. It can be fixed by removing the `println!`.

> `move` in the closure doesn't indicate anything specific to the param list it precedes. It is for the captures variables. May be a common misunderstanding due to its placement.
