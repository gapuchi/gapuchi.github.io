---
layout: post
title: "Monoids and Semigroups"
date: 2019-02-08
categories: [scala]
---

# Monoids and Semigroups

**Monoids** and **semigroups** are type classes that allows us to combine values, such as `Int`, `String`, `Lists`, etc.

## Definition of a Monoid

A **monoid** for a type `A` is

* an operation combine with type `(A, A) => A` that must be *commutative*
* an element `empty` of type `A` that must be an *identity element*

A simplified version of this definition in Cats:

```scala
trait Monoid[A] {
    def combine(x: A, y: A): A
    def empty: A
}
```

```scala
def associaiveLaw[A](x: A, y: A, z: A)(implicit m; Monoid[A]): Boolean = {
    m.combine(x, m.combine(y, z)) == m.combine(m.combine(x, y), z)
}

def identityLaw[A](x: A)(implicit m: Monoid[A]): Boolean = {
    (m.combine(x, m.empty) == x) && (m.combine(m.empty, x) == x)
}
```

So subtraction and division are not monoids, because they aren't associative.

## Definition of a Semigroup

A **semigroup** for a type `A` is the same as `Monoid[A]` without the `empty`.

An updated version of the Scala definition:

```scala
trait Semigroup[A] {
    def combine(x: A, y: A): A
}

trait Monoid[A] extends Semigroup[A] {
    def empty: A
}
```

## Boolean Monoids

There are various ways to combine booleans, so there are various monoids we can create.

```scala
implicit val andMonoid = new Monoid[Boolean] {
    def combine(x: Boolean, y: Boolean) = x && y
    def empty = true
}

implicit val orMonoid = new Monoid[Boolean] {
    def combine(x: Boolean, y: Boolean) = x || y
    def empty = false
}

implicit val xorMonoid = new Monoid[Boolean] {
    def combine(x: Boolean, y: Boolean) = (x && !y) || (!x && y)
    def empty = false
}

implicit val xnorMonoid = new Monoid[Boolean] {
    def combine(x: Boolean, y: Boolean) = (x || !y) && (!x || y)
    def empty = true
}
```

## Set Monoids

There are varioius ways to combine sets.

```scala
implicit def unionMonoid[A]: Monoid[Set[A]] = new Monoid[Set[A]] {
    def combine(x: Set[A], y: Set[A]) = x union y
    def empty = Set.empty[A]
}

implicit def intersectionSemigroup[A]: Semigroup[Set[A]] = new Semigroup[Set[A]] {
    def combine(x: Set[A], y: Set[A]) = x intersect y
    //No identity element for intersection
}

implicit def symDiffMonoid[A]: Monoid[Set[A]] = new Monoid[Set[A]] {
    def combine(x: Set[A], y: Set[A]) = (a union b) diff (a intersect b)
    def empty = Set.empty[A]
}
```

Set difference is not associative, so no monoid/semigroup can be created.