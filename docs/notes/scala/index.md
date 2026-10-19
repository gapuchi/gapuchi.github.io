# Scala

**Big picture:** type classes are ad-hoc polymorphism with laws. The numbered notes climb the hierarchy those classes form. The Cats notes are the same ideas as read from the book.

## Reading order

1. [Type classes](00-type-classes.md): a trait that declares behavior, plus the laws that behavior must obey.
2. [Monoids and semigroups](01-monoids-and-semigroups.md): combining values, with and without an identity.
3. [Functors](02-functors.md): mapping over a structure without changing the structure.
4. [Monads](03-monads.md): sequencing dependent computations.
5. [Semigroupal and applicative](04-semigroupal-and-applicatives.md): combining independent computations.
6. [Foldable and traverse](05-foldable-and-traverse.md): folding a structure, and traversing it with an effect.
7. [Hierarchy](99-heirarchy-of-type-classes.md): how the sequencing type classes sit inside each other.
8. [Higher kinds](higher-kinds-and-type-constructors.md): kinds, the types of types. This is the machinery under functors and everything above them.
9. [Selections](selections.md): variance, and which instance the compiler picks when more than one applies.

## Cats

The same concepts, from *Scala with Cats*, in the order the ideas build.

1. [Type classes](cats/2019-01-19-type-classes.md)
2. [Ad-hoc polymorphism](cats/ad-hoc-polymorphism.md)
3. [Implicits](cats/2019-01-23-implicits.md): how Scala finds the instance.
4. [Monoids](cats/2019-02-18-monoids-cats.md)
