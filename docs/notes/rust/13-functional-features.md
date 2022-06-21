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

Typically when defining functions, you can use `Fn` trait and the compiler will tell you if you need `FnMut` or `FnOnce`.

## Iterators

In rust, iterators are *lazy*. You can use iterators in various ways, including a `for` loop:

```rust
let v1 = vec![1, 2, 3];

let v1_iter = v1.iter();

for val in v1_iter {
    println!("Got: {}", val);
}
```

Iterators abstract the logic of looping through an structure. E.g set an index to, perform an operation, increment index, and stop once there are no items left. This abstraction reduces the chances of errors performed by the user.

### The `Iterator` trait and `next` method

All iterators implement the `Iterator` trait, which is defined the standard library. Looks something like this:

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // methods with default implementations elided
}
```

> `type Item` defines an *associated type* for this trait.

The trait has only one method, which returns one time wrapped in `Some` and `None` once the iterator is over.

```rust
#[test]
fn iterator_demonstration() {
    let v1 = vec![1, 2, 3];

    let mut v1_iter = v1.iter();

    assert_eq!(v1_iter.next(), Some(&1));
    assert_eq!(v1_iter.next(), Some(&2));
    assert_eq!(v1_iter.next(), Some(&3));
    assert_eq!(v1_iter.next(), None);
}
```

> **Note** We needed to make `v1_iter` mutable, because calling `next` on the iterator modifies the internal state of the iterator. (e.g. the tracking of the next item) The `for` loop didn't need to be mutable because the loop took ownership and made it immutable behind the scenes.

The values returned by `next` are immutable references.

* `iter` produces an iterator over immutable references.
* `into_iter` produces an iterator that takes ownership of `v1` and returns owned values.
* `iter_mut` produces an iterator over mutable references.

### Methods that Consume the Iterator

The `Iterator` trait has some methods defined with it. (Check the documentation) Some of these method invokes the `next` method.

These methods that invoke the `next` method are called *consuming adaptors*, since they "consume" the iterator.

An example is `sum`:

```rust
let v1 = vec![1, 2, 3];

let v1_iter = v1.iter();

let total: i32 = v1_iter.sum();

assert_eq!(total, 6);
```

The `sum` method repeatedly calls next and adds the valeus of the iterator. We can't use `v1_iter` after `sum` since it takes ownership of the iterator.

### Methods that Produce Other Iterators

Some methods on the `Iterator` trait changes iterators into different types of iterators. These are called *iterator adaptors*. You can chain these methods to perform complicated computations. Since these are lazy, you have to call a consuming adaptor to get a result from the calls to the iterator adaptors.

A common example, `map`:

```rust
let v1: Vec<i32> = vec![1, 2, 3];

let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();

assert_eq!(v2, vec![2, 3, 4]);
```

### Using Closure that Capture Their Environment

The above `map` method takes in a closure. We can take advantage of closure's ability to capture their environment:

```rust
struct Shoe {
    size: u32,
    style: String,
}

fn shoes_in_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
    shoes.into_iter().filter(|s| s.size == shoe_size).collect()
}
```

In the `shoes_in_size` function, we take the ownership of `shoes` by calling `into_iter` method and provide a closure to `filter` which captures the `shoe_size` from the environment.

> What if we used `iter` instead of `into_iter`?
>
> Compiling fails.
>
> ```rust
> value of type `Vec<Shoe>` cannot be built from `std::iter::Iterator<Item=&Shoe>`
> ```
>
> This is because `iter` creates immutable references, so it returns an iterator of `&Shoe`.

### Creating Iterators with the `Iterator` Trait

We can create our own iterators by implementing the `Iterator` trait. We only need to implement `next` method, after which, you can use all the default methods of the `Iterator` trait.

```rust
struct Counter {
    count: u32,
}

impl Counter {
    fn new() -> Counter {
        Counter { count: 0 }
    }
}

impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.count < 5 {
            self.count += 1;
            Some(self.count)
        } else {
            None
        }
    }
}
```