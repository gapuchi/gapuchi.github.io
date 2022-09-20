# Type Classes

Type classes are used to enable ad-hoc polymorphism, aka overloading.

OO uses subtyping for polymorphism usually. FP uses a combination of parametric polymorphism and ad-hoc polymorphism.

A type class:

1. Declares functionality. (**Traits**)
1. Guarantees behavior. (**Laws**)

In order to learn about a type class, you have to learn these two characteristics. (Laws are especially easy to ignore. Don't.)

> **Remember this is polymorphism.**
>
> A type class **doesn't necessarily define the trait**. There can be **multiple implementations of the trait**, as long as it follows the laws.
>
> That being said, sometimes laws force a specific definition for a function. (E.g. `map` method for `Monad` is defined in terms of `flatMap` and `pure`)

## Data Types and Type Classes

Type classes are used to enable data types to have polymorphism. 

**Data types have a "has-a" relationship with type classes, not a "is-a" relationship.**

* [Correct] Data type `A` has an instance of type class `B`
* [Correct] Data type `A` has 5 different instances of type class `B`
* [Wrong] Data type `A` is a type class `B`
* [Correct] `Either` has an instance of a `Monad`.
* [Wrong] `Either` is a `Monad`.