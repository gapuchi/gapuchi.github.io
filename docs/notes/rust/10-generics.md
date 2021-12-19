# Generic Types, Traits, and Lifetimes

For the sake of conciseness, I'm not explaining generics here. It is the same concept as in Java. This section will include Rust specific syntax and behaviors.

## Generic Data Types

### In Function Definitions

```rust
fn largest<T>(list: &[T]) -> &T {
    let mut largest = &list[0];

    for item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("The largest number is {}", result);

    let char_list = vec!['y', 'm', 'a', 'q'];

    let result = largest(&char_list);
    println!("The largest char is {}", result);
}
```

- `fn largest<T>` - declares a function called `largest` that has a generic type, `T`. 
- `(list: &[T])` - states the method takes in a parameter that is a slice type with the contents of the slice being of type `T`
- `-> &T` - declares the funtion returns a reference to a `T` type

**This won't compile** because there is no guarantee that `T` has a `>` method implemented:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0369]: binary operation `>` cannot be applied to type `T`
 --> src/main.rs:5:17
  |
5 |         if item > largest {
  |            ---- ^ ------- T
  |            |
  |            T
  |
  = note: `T` might need a bound for `std::cmp::PartialOrd`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0369`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

We'll need to use a *trait*, which we'll get to in a moment.

### In Struct Definitions

We can also define structs using generics:

```rust
struct Point<T> {
    x: T,
    y: T,
}

fn main() {
    let integer = Point { x: 5, y: 10 };
    let float = Point { x: 1.0, y: 4.0 };
}
```

### In Enum Definitions

We can also define enums using generics:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

We say that *"`Struct` is generic over two types, `T` and `E`"*.

### In Method Definitions

```rust
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}
```

We have to declare `<T>` after `impl` so we can say we're defining a method for a generic type. You could also define methods for a specific type:

```rust
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

The generics used in a struct doesn't necessarily match those used in the struct's method signatures:

```rust
struct Point<T, U> {
    x: T,
    y: U,
}

impl<T, U> Point<T, U> {
    fn mixup<V, W>(self, other: Point<V, W>) -> Point<T, W> {
        Point {
            x: self.x,
            y: other.y,
        }
    }
}
```

### Performance of Code Using Generics

Rust implements generics in a way that your code *doesn't run any slower using generics types than it would using concrete types*.

It achieves this by performing *monomorphization* at compile type. 

*Monomorphization* - process of turning generic code into specific code by filling in the concrete types that are used when compiled.

Let's take a look at an example with the `Option` enum:

```rust
let integer = Some(5);
let float = Some(5.0);
```

The compiler would see that the `Option` enum is being used for two types: `i32` and `f64`. It expands the definition of `Option<T>` into `Option_i32` and `Option_f64`.

The compiled code will look like this, with `Option<T>` replaced:

```rust
enum Option_i32 {
    Some(i32),
    None,
}

enum Option_f64 {
    Some(f64),
    None,
}

fn main() {
    let integer = Option_i32::Some(5);
    let float = Option_f64::Some(5.0);
}
```

## Traits: Defining Shared Behavior

**Trait** - tells the Rust compiler about a functionality that a type has that can be shared with other types.

We use traits to define shared behavior in an abstract way. We can use *trait bounds* to specific that a generic can be any type that has a certain behavior.

> This is basically *interfaces* in Java, with some caveats.

### Defining a Trait

A type’s behavior consists of the methods we can call on that type. Different types share the same behavior if we can call the same methods on all of those types. Trait definitions are a way to group method signatures together to define a set of behaviors necessary to accomplish some purpose.

```rust
pub trait Summary {
    fn summarize(&self) -> String;
}
```

The methods have `;` at the end because the definition/implementation of the method will be defined by the types that implement this trait.

### Implementing a Trait on a Type

Implementing a trait on a type is similar to implementing regular methonds. The main difference is after `impl`, we put the trait name, then use the `for` keyword, and then specify the name of the type you want to implement the trait for.

```rust
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

We can then use `summarize` as if it was defined in the type:

```rust
let tweet = Tweet {
    username: String::from("horse_ebooks"),
    content: String::from(
        "of course, as you probably already know, people",
    ),
    reply: false,
    retweet: false,
};

println!("1 new tweet: {}", tweet.summarize());
```

**We can only implement a trait on a type only if either the trait or the type is local to our crate.**

- We can implement `Display` (from the standard library) for `Tweet`.
- We can implement `Summary` for `Vec<T>`.
- We **cannot** implement `Display` for `Vec<T>`.

We can't do the third because of *coherence*, or more specifically *the orphan rule* (the parent type is not present). This rule is to ensure no one else breaks your code and vice versa. Without this rule, two crates can create an implementation for the same type and Rust wouldn't know what to do.

### Default Implementations

```rust
pub trait Summary {
    fn summarize(&self) -> String {
        String::from("(Read more...)")
    }
}
```

Rather than a `;`, we can define the methods in the trait for a default implementation.

### Traits as Parameter

We can use traits to define functions:

```rust
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}
```

#### Trait Bound Syntax

This is a syntatical sugar for **trait bound** syntax. The below is equivalent:

```rust
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}
```

The former way is a more concise way, but the latter can express more complicated functions.

If we had a function that took in two `Summary` data types, it would like this:

```rust
pub fn notify(item1: &impl Summary, item2: &impl Summary) {
```

We can pass in an implementation of summary to the first and second.

If we wanted to make sure that both arguments are of the same type (that implements `Summary`), we need to do:

```rust
pub fn notify<T: Summary>(item1: &T, item2: &T) {
```

This ensures that both are of the same type (but implements `Summary`).

#### Specifying Multiple Trait Bounds with the `+` Syntax

```rust
pub fn notify(item: &(impl Summary + Display)) {
```

or 

```rust
pub fn notify<T: Summary + Display>(item: &T) {
```

#### Clearer Trait Bounds with `where` Clauses

A function with multiple generics, each with their own trait bounds, can get pretty verbose and hard to read:

```rust
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {
```

Instead, Rust has the keyword `where`:

```rust
fn some_function<T, U>(t: &T, u: &U) -> i32
    where T: Display + Clone,
          U: Clone + Debug
{
```

This makes the signature less cluttered, and human readable in a way.

### Returning Types that Implement Traits

We can also use the `impl Trait` syntax as a return type:

```
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        retweet: false,
    }
}
```

This syntax **only allows one type to be returned**. The following would return an error at compile time:

```rust
fn returns_summarizable(switch: bool) -> impl Summary {
    if switch {
        NewsArticle {
            headline: String::from(
                "Penguins win the Stanley Cup Championship!",
            ),
            location: String::from("Pittsburgh, PA, USA"),
            author: String::from("Iceburgh"),
            content: String::from(
                "The Pittsburgh Penguins once again are the best \
                 hockey team in the NHL.",
            ),
        }
    } else {
        Tweet {
            username: String::from("horse_ebooks"),
            content: String::from(
                "of course, as you probably already know, people",
            ),
            reply: false,
            retweet: false,
        }
    }
}   
```

`NewsArticle` and `Tweet` both implement `Summary` but the function can only return one of these, due to limitation of the compiler. We will get to how we can make this work later.

### Fixing the largest Function with Trait Bounds

Let's revisit our `largest` function:

```rust
fn largest<T>(list: &[T]) -> &T {
    let mut largest = &list[0];

    for item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}
```

We can add a trait bound to allow the use of `>`:

```rust
fn largest<T: PartialOrd>(list: &[T]) -> T {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}
```

but another issue arises:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0508]: cannot move out of type `[T]`, a non-copy slice
 --> src/main.rs:2:23
  |
2 |     let mut largest = list[0];
  |                       ^^^^^^^
  |                       |
  |                       cannot move out of here
  |                       move occurs because `list[_]` has type `T`, which does not implement the `Copy` trait
  |                       help: consider borrowing here: `&list[0]`

error[E0507]: cannot move out of a shared reference
 --> src/main.rs:4:18
  |
4 |     for &item in list {
  |         -----    ^^^^
  |         ||
  |         |data moved here
  |         |move occurs because `item` has type `T`, which does not implement the `Copy` trait
  |         help: consider removing the `&`: `item`

error: aborting due to 2 previous errors

Some errors have detailed explanations: E0507, E0508.
For more information about an error, try `rustc --explain E0507`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

Data types stored on the stack implement a `Copy` trait, which allows us to *move* `list[0]` into `largest`. With generics, we do not know if the data type implements this trait.

Quick fix is to add another bound trait:

```rust
fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}
```

Other approaches:

- If we don't want to limit to `Copy` we can have it bound by `Clone`, and then clone the element in the logic. We would potentially be making more heap allocations in this case.

```rust
fn largest<T: PartialOrd + Clone>(list: &[T]) -> T {
    let mut largest = list[0].clone();

    for item in list {
        if item > &largest {
            largest = item.clone();
        }
    }

    largest
}
```

- We can implement `largest` to return a reference to `T` value. We do not need `Clone` or `Copy` in this case.

```rust
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];

    for item in list.iter() {
        if item > largest {
            largest = &item;
        }
    }

    largest
}
```

### Using Trait Bounds to Conditionally Implement Methods

We can conditionally create methods on types using trait bounds on `impl` blocks.

```rust
use std::fmt::Display;

struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("The largest member is x = {}", self.x);
        } else {
            println!("The largest member is y = {}", self.y);
        }
    }
}
```

Here we define `new` for all `Pair<T>`, but define `cmp_display` only for `Pair<T>` where `T` implements `Display` and `PartialOrd`.

We can also conditionally implement a trait for any type that implements another trait. This is called **blanket implementations**.

These are used a lot in the Rust library. An example - implementing the `ToString` trait for types that implement `Display` trait.

```rust
impl<T: Display> ToString for T {
    // --snip--
}
```

Because the standard library has this blanket implementation, we can call `to_string` on any type that implements the `Display` trait.

> Blanket implementations appear in the documentation for the trait in the “Implementors” section.

## Validating References with Lifetimes

Every *reference* has a **lifetime** - the scope for which that reference is valid.

Most cases, the lifetime is inferred and implicit, just like how types are inferred most of the time. We need to annotate types when mutliple types are possible).

Similar to this, Rust requires us to annotate lifetimes when the lifetimes of references could be related in more than one way.

Rust requires us to annotate the relationships using generic lifetime parameters to ensure the references at runtime are valid.

### Preventing Dangling References with Lifetimes

The main goal of lifetime is to **prevent dangling references** - which cause a program to reference data other than the data it was meant to reference:

```rust
{
    let r;

    {
        let x = 5;
        r = &x;
    }

    println!("r: {}", r);
}
```

- In the outer scope, we declare `r`
- In the inner scope, we declare `x`
- In the inner scope, we set `r` as a reference to `x`
- Inner scope ends
- We print `r`.

This won't compile because the value `r` is trying to reference has gone out of scope. `x` "didn't live long enough", since its scope ends in the inner scope. `r` is still valid for the outer scope, so "it lives longer".

Rust uses a **borrow checker** to validate this.

### Borrow Checker

The borrow checker compares scopes to determine whether all borrows are valid.

```rust
{
    let r;                // ---------+-- 'a
                          //          |
    {                     //          |
        let x = 5;        // -+-- 'b  |
        r = &x;           //  |       |
    }                     // -+       |
                          //          |
    println!("r: {}", r); //          |
}                         // ---------+
```

lifetime of r is annotated with `'a` and lifetime of x is annotated with `'b`. Rust compares the two lifetimes and sees that the reference lives longer than the subject of the reference.

To fix this:

```rust
{
    let x = 5;            // ----------+-- 'b
                          //           |
    let r = &x;           // --+-- 'a  |
                          //   |       |
    println!("r: {}", r); //   |       |
                          // --+       |
}                         // ----------+
```

Here `r` can reference `x` because its lifetime is shorter.

### Generic Lifetimes in Functions

Working example - write a function that returns the longer of two string slices. The function should take in two string slices and return a single string slice.

```rust
fn main() {
    let string1 = String::from("abcd");
    let string2 = "xyz";

    let result = longest(string1.as_str(), string2);
    println!("The longest string is {}", result);
}

fn longest(x: &str, y: &str) -> &str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

The compiler gives us an error:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0106]: missing lifetime specifier
 --> src/main.rs:9:33
  |
9 | fn longest(x: &str, y: &str) -> &str {
  |                                 ^ expected lifetime parameter
  |
  = help: this function's return type contains a borrowed value, but the signature does not say whether it is borrowed from `x` or `y`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0106`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

Rust cannot tell whether the reference being returned is `x` or `y`. We actually don't know either. The borrow checker cannot tell the concrete lifetimes of the parameters being passed in and the concrete lifetime being returned.

To fix this error, we’ll add generic lifetime parameters that define the relationship between the references so the borrow checker can perform its analysis.

### Lifetime Annotation Syntax

The lifetime annotation doesn't change the lifetime references.

A function can accept a reference with any lifetime by specifying a *generic lifetime parameter*, just like functions can accept any type when the signature specifies a *generic type parameter*.

Lifetime annotations describe the relationships of the lifetimes of multiple references to each other without affecting the lifetimes.

The names of lifetime parameters must start with `'`, usually lowercase and very short. Most people uses `'a`. We place the lifetime parameter annotations after `&`, with a space before the reference's type.

Example:

```rust
&i32        // a reference
&'a i32     // a reference with an explicit lifetime
&'a mut i32 // a mutable reference with an explicit lifetime
```

A single lifetime annotation doesn't have much meaning. The annotations are meant to tell Rust how lifetime annotation parameters of multiple references relate to each other.

For example, in a function we can define two parameters with the same lifetime annotation parameter to indicate the two have the same lifetime.

### Lifetime Annotations in Function Signatures

Like with *generic type parameters*, we define *generic lifetime parameters* inside angle brackets between the function name and parameter list.

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

In the above example, we want the two parameters and the return type to all have the same lifetime, so we declare one lifetime annotation parameter and assign it to each of those.

The function signature now tells Rust that for some lifetime `'a`, the function takes two parameters (both of which are string slices with a lifetime of at least as long as lifetime of `'a`).

This means that the reference returned by the function is the same as the shorter of the two parameters' lifetimes.

Setting the parameter to `'a` doesn't change the lifetime of any reference, rather the value of `'a` is determined by the references.

When we pass the two concrete lifetimes of the references, the concrete lifetime that is substituted for `'a` is the scope of `x` that overlaps with the scope of `y` - aka it will be the shorter of the two lifetimes - aka it will be as long as both lifetimes are valid.

Let's take a look at some examples:

```rust
fn main() {
    let string1 = String::from("long string is long");

    {
        let string2 = String::from("xyz");
        let result = longest(string1.as_str(), string2.as_str());
        println!("The longest string is {}", result);
    }
}
```

`string1` is valid until the end of the outer scope, `string2` is valid until the end of the inner scope. This means `result` is valid until the end of the inner scope.

```rust
fn main() {
    let string1 = String::from("long string is long");
    let result;
    {
        let string2 = String::from("xyz");
        result = longest(string1.as_str(), string2.as_str());
    }
    println!("The longest string is {}", result);
}
```

This fails compilation.

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0597]: `string2` does not live long enough
 --> src/main.rs:6:44
  |
6 |         result = longest(string1.as_str(), string2.as_str());
  |                                            ^^^^^^^ borrowed value does not live long enough
7 |     }
  |     - `string2` dropped here while still borrowed
8 |     println!("The longest string is {}", result);
  |                                          ------ borrow later used here

error: aborting due to previous error

For more information about this error, try `rustc --explain E0597`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

Rust says `string2` didn't live long enough. It knows this because the function signature has generic lifetime annotation parameter among the parameters and return reference. It knows the lifetime of the returned reference is as long as `string2`, so it cannot use the reference outside the scope of `string2`.

### Thinking in Terms of Lifetimes

The way you need to specify lifetime parameters depends on your function.

Example:

```rust
fn longest<'a>(x: &'a str, y: &str) -> &'a str {
    x
}
```

We do not need an annotation on `y` because the lifetime of `y` has no relation with the lifetime of `x` or the return value.

**The lifetime parameter for the return type needs to match the lifetime parameter for one of the parameters when returning a reference from a function.** If it didn't, that means it is referring to a value created in the function, meaning the value will become invalid outside of the function, making the compiler not happy.

This won't compile. Even though we have a lifetime parameter on the return type, it isn't related to one of the parameters of the function. More importantly, it is a dangling reference, so the whole lifetime parameter issue is moot anyway:

```rust
fn longest<'a>(x: &str, y: &str) -> &'a str {
    let result = String::from("really long string");
    result.as_str()
}
```

Giving us this error message:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0515]: cannot return value referencing local variable `result`
  --> src/main.rs:11:5
   |
11 |     result.as_str()
   |     ------^^^^^^^^^
   |     |
   |     returns a value referencing data owned by the current function
   |     `result` is borrowed here

error: aborting due to previous error

For more information about this error, try `rustc --explain E0515`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

### Lifetime Annotations in Struct Definitions

It is possible for structs to hold references, but we would need to add a lifetime annotation on every reference in the struct's definition.

> Quick refresher - why doesn't Rust have the lifetime to be equal to that of the struct?
> 
> The struct has a *reference* to a value and doesn't own it. It doesn't control when it becomes out of scope.

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("Could not find a '.'");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
}
```

Here, `ImportantExcerpt` has a field that is a string slice. Note the angle brackets after the struct name. This annotation means an instance of `ImportantExcerpt` can’t outlive the reference it holds in its part field.

In the example above, `ImportantExcerpt` is created in scope after `novel` which is what provides the `part` field its value. The struct doesn't go out of scope after `novel`.

### Lifetime Elision

The following method compiles without lifetime annotations:

```rust
fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }

    &s[..]
}
```

We expect the refernces to have lifetime annotations:

```rust
fn first_word<'a>(s: &'a str) -> &'a str {
```

but this got super repetitive. The compiler was made to infer the lifetimes in these specific examples.

**Lifetime elision rules** are these patterns programmed into Rust's analysis of references. If the compiler finds a specific pattern, we do not need to specify the lifetimes.

**The rules do not provide full inferences, though**. If there are some references without a lifetime annotation after the elision rules are applied, the compiler will fail.

input lifetimes
: lifetimes on function/method parameters

output lifetimes
: lifetiems on return values

The rules:

1. Each parameter that is a reference gets its own lifetime annotation.
1. If there is exactly one input lifetime parameter, that lifetime is assigned to all output lifetime parameters.
1. If there are multiple input lifetime parameters, but one is `&self` or `&mut self` (indicating this is a method, not a function), the lifetime of `self` is assigned to all output lifetime parameters.

> **Example 1**
>
> `fn first_word(s: &str) -> &str {`
>
> `fn first_word<'a>(s: &'a str) -> &str {    // Rule 1`
>
> `fn first_word<'a>(s: &'a str) -> &'a str { // Rule 2`
>
> The compiler stops, since all references have a lifetime.

> **Example 2**
>
> `fn longest(x: &str, y: &str) -> &str {`
>
> `fn longest<'a, 'b>(x: &'a str, y: &'b str) -> &str { // Rule 1`
>
> Rule 2 doesn't apply since there is more than 1 input lifetime parameter.
>
> Rule 3 doesn't apply since this is a function, not a method.
>
> Compiler fails, since we couldn't figure out the lifetimes of all the signature.

### Lifetime Annotations in Method Definitions

We implement methods on structs with lifetimes by using the same syntax as generics.

TBD

### The Static Lifetime

`'static` lifetime means the reference can live for the entire duration of the program.

All string literals have the `'static` lifetimes.

We can annotate strings like:

```rust
let s: &'static str = "I have a static lifetime.";
```

The text of the string is stored in the binary, so it's always available.

Double check if you really need static lifetime parameters....