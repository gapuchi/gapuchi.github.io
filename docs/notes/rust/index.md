# Rust

**Big picture:** the Rust book's concepts, in the order they depend on each other. Ownership is the center. Everything before it is the language you need in order to see what ownership is restricting.

## Reading order

1. [Variables and mutability](03.1-variables-mutability.md): bindings, `mut`, constants, and shadowing.
2. [Data types](03.2-data-types.md): scalars, compounds, and how values are stored.
3. [Functions](03.3-functions.md): parameters and return values.
4. [Control flow](03.5-control-flow.md): `if`, loops, and expressions.
5. [Ownership](04-ownership.md): which binding owns a value, and when it is dropped.
6. [Structs](05-structs.md): grouping related data, and how ownership applies to fields.
7. [Enums](06-enums.md): one value of several shapes, and pattern matching.
8. [Packages, crates, and modules](07-managing-projects.md): how code is split and made visible.
9. [Error handling](09-error-handling.md): `Result` and `Option` instead of exceptions.
10. [Generics, traits, and lifetimes](10-generics.md): one implementation, many types, and how long a reference lives.
11. [Functional features](13-functional-features.md): closures and iterators.
12. [Smart pointers](15-smart-pointers.md): `Box`, `Rc`, and `RefCell` when a plain owner is not enough.
