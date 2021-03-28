---
layout: post
title: Structs
part: 6
---

# Using Structs to Structure Related Data

A *struct* is a custom data type. It is like an object's data attributes if you're thinking about object-oriented programming.

## Defining and Creating Structs

Structs are similar to tuples. They both can contain elements of different types. In struct, these elements are named. To define the struct:

```rust
struct User {
    username: String, //This is a field
    email: String,
    sign_in_count: u64,
    active: bool,
}
```

We create an *instance* of a struct by defining each of the *fields*.

```rust
let user1 = User {
    email: String::from("someone@example.com"),
    username: String::from("someusername123"),
    active: true,
    sign_in_count: 1,
};
```

The order doesn't matter, because the fields are named. (An advantage over tuples.)

We can use dot notation to get specific attributes from a struct (`user1.email`). If this is mutable we can change it via this way of accessing:

```rust
user1.email = String::from("anotheremail@example.com")
```

The **entire struct must be mutable**. We cannot mark specific fields as mutable.

### Using the Field Init Shorthand when Variables and Fields Have the Same Name

Let's say we have a function:

```rust
fn build_user(email: String, username: String) -> User {
    User {
        email: email,
        username: username,
        active: true,
        sign_in_count: 1,
    }
}
```

we can just simply have it to be:

```rust
fn build_user(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
        sign_in_count: 1,
    }
}
```

### Creating Instances From Other Instances With Struct Update Syntax

There will be cases where we want to create a struct with most of an old struct's field with some changed. We can use the *struct update syntax*.

Instead of:

```rust
let user2 = User {
    email: String::from("another@example.com"),
    username: String::from("anotherusername567"),
    active: user1.active,
    sign_in_count: user1.sign_in_count,
};
```

we can have:

```rust
let user2 = User {
    email: String::from("another@example.com"),
    username: String::from("anotherusername567"),
    ..user1
};
```

The `..` specifies that the remaining fields not set should have the same values as the fields in the given instance.

### Using Tuple Structs without Named Fields to Create Different Types

You can define structs that look like tupes, called *tupled structs*. They do not have names associated to the fields, rather they types associated to the fields. This is useful when you want to give a tuple a meaning, and make it a different type from other tupes, where field names are redundant.

```rust
fn main() {
    struct Color(i32, i32, i32);
    struct Point(i32, i32, i32);

    let black = Color(0, 0, 0);
    let origin = Point(0, 0, 0);
}
```

### Unit-Like Structs Without Any Fields

You can have structs without any fields. This is useful for when you want to implement a trait that doesn't any data itself.

### Ownership of Struct Data

The examples above, the fields are owned by the struct. We can have structs with fields that are owned by something else, but to do so we need to use *lifetimes*. Lifetimes esnure that the data references by a struct is valid for as long as the struct is. This will be further explained later.

## An Example Program

[Example Programs](src/ch-5)

## Method Syntax

### Defining Methods

Let's modify the example in the previous section:

```rust
[derive(Debug)]
struct Rect {
    width: u32,
    height: u32,
}

impl Rect {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

fn main() {
    let rect1 = Rect {
        width: 30,
        height: 50,
    };

    println!(
        "The area of the rectangle is {} square pixels.",
        rect1.area()
    );
}
```

To define the function within a context of `Rect`, we have to define an `impl` (implementation) block. We move the `area` function to this block and change the param to be `self`.

We use `self` instead of `rect: &Rect` because Rust knows the type for `&self`. (We still need to pass in a reference because methods can take ownership, reference immutably, or reference mutably.)

Having a method that takes ownership is rare. Usually we see this only when the method transforms `self` into something else and you want to prevent the caller from using the original.

### Methods with More Parameters

If you want to use more parameters:

```rust
impl Rect {
    fn area(&self) -> u32 {
        self.width * self.height
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```

### Associated Functions

We can define functions that do not take in `self` in the `impl` block. These are called *associated functions* because they are associated with the struct. They are functions, not methods because they are not associated with an instance. `String::from` is an example.

Associated functions are often used for constructors:

```rust
impl Rect {
    fn square(size: u32) -> Rect {
        Rect {
            width: size,
            height: size,
        }
    }
}
```

To call an associated function, we use `::` - `let sq = Rect::square(3);`

### Multiple Impl Blocks

We have multiple `impl` blocks, and all will be considered. Not sure why we'd want to do this, but it is possible.
