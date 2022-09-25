# Managing Growing Projects with Packages, Crates, and Modules

* So far we've written code in one **module** in one **file**.
* As code gets bigger, we can split our code into multiple modules and then in multiple files.
* **Package** contains **multiple binary crater** and **optionally one library crate**. (Why only one library? Idk).
* As your project grows, you can split code into different crates.
* This leads to the concept of **scope**. The context where code is written has a set of names that are defined as *in scope*. You can create scopes and change which names are in and out of the scope. You can't have two itesm with the same name in the same scope.

Rust provides introduces various tools:

<dl>
    <dt>Packages</dt>
    <dd>A Cargo feature that lets you build, test, and share crates</dd>
    <dt>Crates</dt>
    <dd>A tree of modules that produces a library or executable</dd>
    <dt>Modules, use</dt>
    <dd>Lets you control the organization, scope, and privacy of paths</dd>
    <dt>Paths</dt>
    <dd>A way of naming an item, such as a struct, function, or module</dt>
</dl>

## Packages and Crates

<dl>
    <dt>Crate</dt>
    <dd>A binary or library</dd>
    <dt>crate root</dt>
    <dd>A source file that the Rust compiler starts from and makes up the root module of your crate.</dd>
    <dt>Package</dt>
    <dd>One or more crates that provide a set of functionality. It contains a *Cargo.toml* file that explains how to build these crates.</dd>
</dl>

A *package*:

1. **Must contain** at least one crate (either a library crate or binary crate)
1. Cannot contain more than one library crate
1. Can contain as many binary crates as you want

Let's create a new project:

```zsh
~ $ cargo new my-new-project
     Created binary (application) `my-new-project` package
~ $ ls my-new-project 
Cargo.toml src
~ $ ls my-new-project/src
main.rs
~ $ cat my-new-project/Cargo.toml 
[package]
name = "my-new-project"
version = "0.1.0"
authors = ["Spongebob Squarepants <bob.sponge@krustykrab.com>"]
edition = "2018"

 See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
~ $
```

Couple of things to note here:

1. There is a *Cargo.toml* file, indicating that this is a package.
1. *Cargo.toml* has no mention of `src/main.rs`. Cargo follows the convention of:
    * `src/main.rs` - crate root of a binary crate with the same name as the package.
    * `src/lib.rs,` - crate root of a library crate with the same name as the package.
1. Cargo passes the crate root files to `rustc` to build the library or binary.
1. This package only has `src/main.rs` so it only contains a binary crate named `my-project`.
1. If the package contains both `src/main.rs` and `src/lib.rs`, it has two crates:
    1. A binary crate named `my-project`
    1. A library crate named `my-project`
1. A package can have multiple binary crates by placing files under `src/bin`. Each file is a separate binary crate.

*A crate will group related functionality together in a scope so its easy to share among projects.*

For example, the `rand` crate provides the functionality of generating random numbers. We can use this by bringing `rand` crate into our project's scope. All functionality can be through the crate's name, `rand`.

Keeping a crate's functionality in its own scope prevents conflicts. For example, `rand` provides a trait `Rng`. We can also create a struct `Rng` in our own crate. We can bring in `rand` as a dependency and the compiler wouldn't be confused on which `Rng` we're using. In our crate it refers to our struct `Rng`. If we wanted to use the one in `rand`, we'd access it by saying `rand::Rng`.

## Defining Modules to Control Scope and Privacy

**Modules** let us organize code within a crate into groups for readability and easy reuse. It also controls **privacy**.

Example, a module for restaurant functionality. We create `src/lib.rs` to create a library crate. Inside this class, we can define modules and functions:

```rust
// src/lib.rs
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}

        fn seat_at_table {}
    }

    mod serving {
        fn take_order() {}

        fn serve_order() {}

        fn take_payment() {}
    }
}
```

We use `mod` keyword to define a module and use `{}` to define the mody of the module. 

Inside a module, we can define other modules and hold definitions for other items, such as structs, enums, constants, traits, or functions.

You know how `src/lib.rs` and `src/main.rs` are called *crate root*s? This is because the contents of these files form the a module called `crate` that is at the root of the module tree.

```rust
crate
 └── front_of_house
     ├── hosting
     │   ├── add_to_waitlist
     │   └── seat_at_table
     └── serving
         ├── take_order
         ├── serve_order
         └── take_payment
```

Things to note:

1. `hosting` *nests* inside `front_of_house`
1. `hosting` is *siblings* with `serving`
1. `hosting` is the *child* of `front_of_house`
1. `front_of_house` is the *parent* of `hosting`

## Paths for Referring to an Item in the Module Tree

We use paths to find an item in the module tree structure.

A path can take two forms:

1. *Absolute path* - starts from a crate root by using a crate name or a literal `crate`
1. *Relative path* - starts from the current module and uses `self`, `super`, or an identifier in the current module.

The identifiers are separated by `::` in a path.

So if we wanted to access `add_to_waitlist` from the root:

```rust
mod front_of_house { ... }

pub fn eat_at_restaurant() {
    //absolute path
    crate::front_of_house::hosting::add_to_waitlist();

    //relative path
    front_of_house::hosting::add_to_waitlist();
}
```

This actually won't compile because **`hosting` is private**.

* Modules define privacy boundaries. All items are private by default.
* Parent modules cannot access private items inside child modules
* Child modules can access private items in their ancestor modules.
    * This is because child hides implementation from the parent, but the child is aware of the context they're defined in.
* Use `pub` to make an item public.

### Exposing Paths with the pub Keyword

Let's make that function accessible:

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // Absolute path
    crate::front_of_house::hosting::add_to_waitlist();

    // Relative path
    front_of_house::hosting::add_to_waitlist();
}
```

Note:

* We had to make both the `hosting` and `add_to_waitlist` public.
* We didn't have to make `front_of_house` public. `eat_at_restaurant` is siblings with `front_of_house` so it can access it.

### Starting Relative Paths with `super`

tldr - use `super` to up one module when using relative paths.

### Making Structs and Enums Public

We use `pub` to make structs and enum public. Things to note:

1. Marking a struct public doesn't make the fields public. We have to mark whichever fields we want to be public with `pub` as well.
1. If a struct has private fields, it needs a public associated function that constructs an instance of the struct.
    1. Otherwise we can't create an instance outside of the module. (Is this required if we don't want to access it outside of the module? My guess is it is because why else would we mark the struct as `pub`?)

```rust
mod back_of_house {
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("peaches"),
            }
        }
    }
}

pub fn eat_at_restaurant() {
    // Order a breakfast in the summer with Rye toast
    let mut meal = back_of_house::Breakfast::summer("Rye");
    // Change our mind about what bread we'd like
    meal.toast = String::from("Wheat");
    println!("I'd like {} toast please", meal.toast);

    // The next line won't compile if we uncomment it; we're not allowed
    // to see or modify the seasonal fruit that comes with the meal
    // meal.seasonal_fruit = String::from("blueberries");
}
```

1. Marking an enum public makes all its variants public. You only need to mark the enum as `pub`.

```rust
mod back_of_house {
    pub enum Appetizer {
        Soup,
        Salad,
    }
}

pub fn eat_at_restaurant() {
    let order1 = back_of_house::Appetizer::Soup;
    let order2 = back_of_house::Appetizer::Salad;
}
```

## Bringing Paths into Scope with the `use` Keyword

Instead of declaring the whole path each time we want to use an item, we can bring the path into scope with `use`.

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

With this, `hosting` can be treated as if *it was defined in the scope*

You can also use with relative paths.

### Creating Idiomatic use Paths

Why not specify the `use` path all the way to `add_to_waitlist`? *This is possible*, but the **idiomatic way is to bring the module into scope, not the function**. This way we can make it apparent that the function isn't defined in the scope.

**The idiomatic way to bring in strucst, enums, and other items is to use the full path**. Weird right?

There really isn't a reason, just the convention that formed.

The only limitation is that we can't bring two items with the same name into the same scope:

```rust
use std::fmt;
use std::io;

fn function1() -> fmt::Result {
    // --snip--
    Ok(())
}

fn function2() -> io::Result<()> {
    // --snip--
    Ok(())
}
}
```

We clarify `Result` by using the `fmt` or `io` module. We couldn't do 

```rust
use std::fmt::Result;
use std::io::Result;
```

because Rust wouldn't know which one to use if we were to refer to `Result`.

### Providing New Names with the as Keyword

A work around to bring in items with the same name is to rename an item with `as` keyworkd:

```rust
use std::fmt::Result;
use std::io::Result as IoResult;
```

### Re-exporting Names with pub use

* `use` brings a name into the scope, but the name is private
* If we want to allow external code to access this name in given module, we can slap on a `pub` in front of `use`

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

Things to note:

1. External code can call `add_to_waitlist` by `hosting::add_to_waitlist`.
1. External code *cannot* call `add_to_waitlist` because `front_of_house` is not public.

<dl>
    <dt>When to use?</dt>
    <dd>The internal structure of your code differs from how users would think about the domain. (e.g. users wouldn't not distinguish "back of house" and "front of house")</dd>
</dl>

### Using External Packages

To use (for example) `rand` package, we add this line to *Cargo.toml*:

```rust
[dependencies]
rand = "0.0.5"
```

then to bring `rand` into scope, we add a `use` line:

```rust
use rand::Rng; //Starts with the crate name (rand) and then followed by the item/module etc.
```

`std` (standard library) is an external package that is shipped with Rust, so we do not neet to declare it as a dependency, but we do need to declare a `use` statement if we want to use something from it.

### Using Nested Paths to Clean Up Large `use` Lists

```rust
use std::cmp::Ordering;
use std::io;
```

can be simplified to:

```rust
use std::{cmp::Ordering, io};
```

and

```rust
use std::io;
use std::io::Write;
```

can be simplified to:

```rust
use std::io::{self, Write};
```

### Glob Operator

If we want to bring in all public items in a path, use `*` (the *glob operator*):

```rust
use std::collections::*;
```

## Separating Modules into Different Files

We want to split modules into different files when it gets too big.

Let's move `front_of_house` into its own file. We create `src/front_of_house.rs`:

```rust
pub mod hosting {
    pub fn add_to_waitlist() {}
}
```

and change `src/lib.rs` to be:

```rust
mod front_of_house; //The semi-colon instead of a body tells Rust to load the contents from another file with the same name as the module.

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

Let's extract `hosting` to its own file:

```rust
// src/front_of_house.rs
pub mod hosting;
```

and we create `src/front_of_house/hosting.rs`:

```rust
pub fn add_to_waitlist() {}
```

A way to think about the structure is to look at the path: `crate::front_of_housing::hosting` can be converted to `src/front_of_housing/hosting.rs`.
