# Ownership

**Ownership Rules**:

1. Each value in Rust has a variable called its *owner*.
1. There can only be one owner at a time.
1. When the owner goes out of scope, the value will be dropped.

## Variable Scope

```rust
let s = "hello";
```

The variable is valid from the point at which it’s declared until the end of the current scope.

```rust
{
    //s is invalid
    let s = "hello"; //s is valid
    //s is valid
} //end of scope, s is invalid
```

## The `String` Type - An Example

The data types mentioned above are stored on the stack and are popped off when moved out of scope. Let's take a look at an example of something stored on the *heap*.

There are string literals, but there are cases where we can't use a literal. Rust has `String` type for this case. We can create one from a literal:

```rust
let s = String::from("hello");
```

Unlike literals, this can be mutated:

```rust
let mut s = String::from("hello");

s.push_str(", world!"); // push_str() appends a literal to a String

println!("{}", s); // This will print `hello, world!`
```

Why can this be mutated but not literals? This can be explained by how these are stored.

## Memory and Allocation

With a string literal, we know the contents at compile time. The text is hardcoded directly into the final executable. We can do this because a **literal is immuatable**. We cannot allocate memory for each text that we do not know the size of, or those that might change.

We need allocate memory on the heap to allow storage of unknown memory that may be changing. So

1. The memory must be requested from the memory allocator **at runtine**.
1. The memory needs to be returned to the allocator when we're done with the `String`.

`String::from` does the first part for us. (This basically happens for all languages).

The second part is different. Rust doesn't have a garbage collector like other languages, that clean up for them. We need to do this ourselves.

Well, "by ourselves" really means Rust. The memory is automatically returned once the variable that owns it goes out of scope.

```rust
fn main() {
    {
        let s = String::from("hello"); // s is valid from this point forward

        // do stuff with s
    }                                  // this scope is now over, and s is no longer valid
}
```

When a variable goes out of scope, Rust calls a special function, `drop`. The author of `String` puts the code to return the memory in this method. Rust calls it automatically.

### Ways Variables and Data Interact: Move

Multiple variables can interact with the same data:

```rust
let x = 5;
let y = x;
```

`5` is bound to `x` and a copy is bound to `y`. This data is known and stored onto the stack.

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;
}
```

In this case, `s1` isn't copied to `s2`, because it isn't stored on the stack.

A `String` is made up of three things:

1. A pointer to the memory that holds the content of the string
1. Length
1. Capacity

These three are stored on the stack. The content of the string is stored on the heap. When we assign `s1` to `s2`, the `String` data is copied, meaning the pointer, length, and capacity are assigned to `s2`.

When a variable goes out of scope, Rust calls `drop`. **It is a bug to drop the same memory twice**. This is called a **double free error**. Freeing memory twice can lead to memory corruption, which can potentially lead to security vulnerabilities. So what happens with `s1` and `s2`, since they both look at the same location in memory?

Rust ensures memory safety by *invalidating `s1`*:

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;

    println!("{}, world!", s1); //Error
}
```

Instead of a *shallow copy*, where the pointer is copied, this is a **move** because `s1` is invalidated. `s1` was *moved* to `s2`. Rust will never automatically *deep copy* your data, as this is expensive.

### Ways Variables and Data Interact: Clone

If we want to do a **deep copy**, we can use a common method called **clone**:

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1.clone();

    println!("s1 = {}, s2 = {}", s1, s2);
}
```

### Stack-Only Data: Copy

You know what's weird:

```rust
fn main() {
    let x = 5;
    let y = x;

    println!("x = {}, y = {}", x, y);
}
```

The above doesn't error. Didn't `x` move to `y`? Well this these data types have known size at compile time and are stored on the stack, the copies are made quickly. No need to invalidate the previous variable. There is no such thing as a shallow copy because the actual value gets copied in the stack.

Rust has a `Copy` trait that we can put on data types such as integers. If a type has a `Copy` trait, the older variable is still usable after reassignment. Rust won't let us annotate a type with `Copy` trait if the type or any part of it has implemented the `Drop` trait.

## Ownership and Functions

Passing a value to the function similar is assigning:

```rust
fn main() {
    let s = String::from("hello");  // s comes into scope

    takes_ownership(s);             // s's value moves into the function...
                                    // ... and so is no longer valid here

    let x = 5;                      // x comes into scope

    makes_copy(x);                  // x would move into the function,
                                    // but i32 is Copy, so it’s okay to still
                                    // use x afterward

} // Here, x goes out of scope, then s. But because s's value was moved, nothing
  // special happens.

fn takes_ownership(some_string: String) { // some_string comes into scope
    println!("{}", some_string);
} // Here, some_string goes out of scope and `drop` is called. The backing
  // memory is freed.

fn makes_copy(some_integer: i32) { // some_integer comes into scope
    println!("{}", some_integer);
} // Here, some_integer goes out of scope. Nothing special happens.
```

* `s` is moved to `some_string`. We cannot use `s` after this.

## Return Values and Scope

```rust
fn main() {
    let s1 = gives_ownership();         // gives_ownership moves its return
                                        // value into s1

    let s2 = String::from("hello");     // s2 comes into scope

    let s3 = takes_and_gives_back(s2);  // s2 is moved into
                                        // takes_and_gives_back, which also
                                        // moves its return value into s3
} // Here, s3 goes out of scope and is dropped. s2 goes out of scope but was
  // moved, so nothing happens. s1 goes out of scope and is dropped.

fn gives_ownership() -> String {             // gives_ownership will move its
                                             // return value into the function
                                             // that calls it

    let some_string = String::from("hello"); // some_string comes into scope

    some_string                              // some_string is returned and
                                             // moves out to the calling
                                             // function
}

// takes_and_gives_back will take a String and return one
fn takes_and_gives_back(a_string: String) -> String { // a_string comes into
                                                      // scope

    a_string  // a_string is returned and moves out to the calling function
}
```

What if we want to let a function use a value but not take ownership? We can return the original variable back:

```rust
fn main() {
    let s1 = String::from("hello");

    let (s2, len) = calculate_length(s1);

    println!("The length of '{}' is {}.", s2, len);
}

fn calculate_length(s: String) -> (String, usize) {
    let length = s.len(); // len() returns the length of a String

    (s, length)
}
```

It is extra code and an extra process. For these cases, Rust has a concept called *references*.

## References and Borrowing

Here's how a function would take a parameter as a reference without taking ownership:

```rust
fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);

    println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}
```

We pass `&s1` to the function and the function definition takes `&String`.

The `&` are references (and `*` is a dereference operator, more on that later).

`s: &String` means that `s` is a reference to a String. Once it goes out of scope, the value it reference **does not**, because `s` doesn't own it.

Having references as function parameters is called **borrowing**. Because the function doesn't own it, it cannot modify it.

References are immutable, like variables are by default.

### Mutable References

To make a reference mutable, we have to:

```rust
fn main() {
    let mut s = String::from("hello");

    change(&mut s);
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");
}
```

Couple of things:

1. Change `s` to be `mut`
1. Create mutable reference, `&mut s`
1. Change the function to accept a mutable reference, `some_string: &mut String`

You can have **only one mutable reference to a particular piece of data**:

```rust
fn main() {
    let mut s = String::from("hello");

    let r1 = &mut s;
    let r2 = &mut s; //Error

    println!("{}, {}", r1, r2);
}
```

This restriction prevents *data races* from occurring.

We can use `{}` to create a new scope to allow multiple mutable references, just not at the same time:

```rust
fn main() {
    let mut s = String::from("hello");

    {
        let r1 = &mut s;
    } // r1 goes out of scope here, so we can make a new reference with no problems.

    let r2 = &mut s;
}
```

You cannot combine mutable and immutable references:

```rust
fn main() {
    let mut s = String::from("hello");

    let r1 = &s;
    let r2 = &s;
    let r3 = &mut s; //Error

    println!("{}, {}, and {}", r1, r2, r3);
}
```

A reference's scope starts from where it is introduced to where it is last used.

So this is fine:

```rust
fn main() {
    let mut s = String::from("hello");

    let r1 = &s; // no problem
    let r2 = &s; // no problem
    println!("{} and {}", r1, r2);
    // r1 and r2 are no longer used after this point

    let r3 = &mut s; // no problem
    println!("{}", r3);
}
```

### To Summarize

1. You can either have one mutable or any number of immutable references.
1. References must always be valid.

## The Slice Type

An example - Write a function that takes a string and returns the first word it finds in that string. If no word is found, then the whole string should be returned.

The signature of the function:

```rust
fn first_word(s: &String) -> ?
```

We have one parameter that takes in a reference to a string. We do not want ownership, so that's fine. What do we return?

One example is to return an index:

```rust
fn first_word(s: &String) -> usize {
    let bytes = s.as_bytes(); //Convert a string into an array to check every element

    for (i, &item) in bytes.iter().enumerate() { //Create an iterator
        if item == b' ' { //Compare  to the byte literal space
            return i;
        }
    }

    s.len()
}
```

The only problem here - the `usize` returned here only has meaning in the context of `&String`. We have no guarantee that it will be valid in the future. Something could modify the `&String`:

```rust
fn main() {
    let mut s = String::from("hello world");

    let word = first_word(&s); // word will get the value 5

    s.clear(); // this empties the String, making it equal to ""

    // word still has the value 5 here, but there's no more string that
    // we could meaningfully use the value 5 with. word is now totally invalid!
}
```

This compiles without any issues. We need to worry about keeping `word` in sync with `s`. Plus if we decided to get the second word from the string, it becomes more complicated, having to return the start and end indices.

The solution? String slices

### String Slices

**Slice** references a sequence of elements in a collection, instead of a whole collection. It **does not have ownership**.

A *string slice* is a reference to part of a `String`

```rust
fn main() {
    let s = String::from("hello world");

    let hello = &s[0..5];
    let world = &s[6..11];
}
```

With Rust's range syntax `..`, you can drop the value before the dots if you want to start at the 0 index. If you want to include the last byte, you can drop the value after `..`. The type that signifies “string slice” is written as `&str`.

A function to find the first word:

```rust
fn first_word(s: &String) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }

    &s[..]
}
```

Rust compiler ensures that references to the string remain valid. So now this would error at compile time:

```rust
fn main() {
    let mut s = String::from("hello world");

    let word = first_word(&s);

    s.clear(); // error!

    println!("the first word is: {}", word);
}
```

Rust doesn't let you have a mutable reference if you already have an immutable reference. `clear` needs a mutable reference (because it is modifying the string), but we passed an immutable reference to `first_word`.

### String Literals Are Slices

```rust
let s = "Hello, world!";
```

Recall string literals being stored inside the binary. The type of `s` here is `&str`: it’s a slice pointing to that specific point of the binary. This is also why string literals are immutable; `&str` is an immutable reference.

### String Slices as Parameters

One improvement to the signature:

```rust
fn first_word(s: &String) -> &str {
```

can be written as:

```rust
fn first_word(s: &str) -> &str {
```

This allows us to use the same function for `&String` and `&str`.

If we have a string slice, we can pass it directly. If we have a string, we can pass a slice of the whole string.

```rust
fn main() {
    let my_string = String::from("hello world");

    // first_word works on slices of `String`s
    let word = first_word(&my_string[..]);

    let my_string_literal = "hello world";

    // first_word works on slices of string literals
    let word = first_word(&my_string_literal[..]);

    // Because string literals *are* string slices already,
    // this works too, without the slice syntax!
    let word = first_word(my_string_literal);
}
```

### Other Slices

We can take a slice of arrays besides strings:

```rust
let a = [1, 2, 3, 4, 5];
let slice = &a[1..3];
```

The slice has the type `&[i32]`.
