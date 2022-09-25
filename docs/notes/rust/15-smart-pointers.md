# Smart Pointers

Generally, a *pointer* is a variable that contains an address in memory.

In Rust, the most common point is a *reference*, which is indicated by the `&` and the value they point to. They have no other functionality than to refer to the data. They have no overhead.

> Why don't they have overhead? What does overhead mean here?

***Smart pointers* are data structures that act like a pointer**, but also have additional metadata and capabilities.

> Smart pointers originated in C++ and exist in other languages.

Rust provides a variety of spark pointers defined in the standard library that provide functionality beyond that provided by references.

In Rust, another distinction between *references* and *smart pointers* - references borrow data, smart pointers own the data they point to in many occassions.

`String` and `Vec<T>` are examples of smart pointers because they own some memory and allow you to manipulate it.

- `String` stores its capacity as metadata and has the extra ability to ensure its data will always be valid UTF-8.

```
//TODO Explain why String and Vec are
```

Smart pointers are usually implemented using structs and implements the `Deref` and `Drop` traits.

- `Deref` trait allows an instance of the smart pointer struct to behave like a reference. That way you can write your code to work with either references or smar pointers.
- `Drop` trait allows you to customize the code that's run whena an instance of the smart pointer goes out of scope.

Smart pointer pattern is a general design pattern used frequently in Rust. Some common smart pointers in the standard library:

- `Box<T>` for allocating values on the heap
- `Rc<T>`, a reference counting type that enables multiple ownership
- `Ref<T>` and `RefMut<T>`, accessed through `RefCell<T>`, a type that enforces the borrowing rules at runtime instead of compile time

## `Box<T>` to Store Data on the Heap

### Syntax

If we want to store an `i32` value on the heap:

```rust
fn main() {
    let b = Box::new(5);
    println!("b = {}", b);
}
```

- The variable `b` has the value of a `Box` that points to the value `5`, which is allocated on the heap.
- The program will print `b = 5`. We can access the data in the box similar to how we would if this data were on the stack.
- When a box goes out of scope, it will be deallocated, like any owned value. The deallocation happens both for the box (stored on the stack) and the data it points to (stored on the heap).

A single value on the heap isn't much use, since it can easily be stored on the stack. We'll see some examples on why we need boxes.

### Achieving Recursive Types with Boxes

A value of *recursive type* can have another value of the same type as part of itself.

Rust needs to know how much space a type takes up, which makes recursive types a problem for Rust. Recursive types could go on infinitely, so Rust cannot know how much space to allocate. Boxes have a known size, so we can enable recursive types by using boxes.

#### Example - *cons list*

A *cons list* is a data structure made of nested pairs. It originates from Lisp and is its version of a linked list.

> The name comes from the `cons` (short for "construction") function in Lisp that constructs a new pair from its two arguments.

So for example, the list 1, 2, 3:

```
(1, (2, (3, Nil)))
```

> It's not really a useful data structure in Rust (it has `Vec`) but it is good for this example.

So our first attempt:

```rust
enum List {
    Cons(i32, List),
    Nil,
}
```

This won't compile since `List` doesn't have a known size. The compiler will complain that `List` has infinite size.

> #### Computing the Size of a Non-Recursive Type
> 
> ```rust
> enum Message {
>     Quit,
>     Move { x: i32, y: i32 },
>     Write(String),
>     ChangeColor(i32, i32, i32),
> }
> ```
>
> To determine how much space to allocate for a `Message` value, Rust goes through each of the variants of see which variant needs the most space.
> 
> - `Message::Quit` doesn't need any space //Why no space?
> - `Message::Move` needs enough space to store two `i32` values
> - etc.
>
> Since one `Message` variant will be used, we only need as much space as the largest one.

Let's see Rust try to determine the size of `List`. It sees the first variant as `Cons` and it determines it needs the space for one `i32` and one `List`. Rust then tries to solve this `List`, and so on. So it sees `i32` + `i32` + `i32` + `i32` + ... infinitely.

The compiler suggests "indirection":

```
help: insert some indirection (e.g., a `Box`, `Rc`, or `&`) to make `List` representable
  |
2 |     Cons(i32, Box<List>),
  |               ^^^^    ^
```

*Indirection* means that instead of storing a value indirectly, we should change the data structure to store the value indirectly by storing a pointer to the value instead.

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}
```

Now when Rust determines the size, it knows how much space `Box<T>` takes - the pointer size doesn't change based on the the amount of data it's pointing to.

Boxes provide only the indirection and heap allocation. No other special capabilities (like other smart pointers). No performance overhead that comes with the special capabilities either.

`Box<T>` type is a smart pointer because it implements the `Deref` trait, which allows `Box<T>` values to be treated like references. When `Box<T>` value goes out of scope, the heap data that the box is pointing to is cleaned up as well because of the `Drop` trait implementation.