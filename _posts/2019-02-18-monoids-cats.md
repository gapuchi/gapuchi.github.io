---
layout: post
title: "Monoids in Cats"
date: 2019-02-18
categories: [scala, cats]
---

# Monoids in Cats

## Monoid Type Class

`cats.kernel.Monoid` (aliased [`cats.Monoid`](https://typelevel.org/cats/api/cats/kernel/Monoid.html)) extends `cats.external.Semigroup` (alias [`cats.Semigroup`](https://typelevel.org/cats/api/cats/kernel/Semigroup.html)).

> Cats Kernel
>
> A subproject of Cats to provide a small set of type classes for libraries that don't need the full Cats toolbox. They are in the `cats.kernel` package, but they are aliased as `cats`.

## Monoid Instances

`Monoid` has the same Cats pattern for the user interface, a companion object has an `apply` method.

```scala
import cats.Monoid
import cats.instances.string._ // for Monoid

Monoid[String].combine("Hi ", "there")
// res0: String = Hi there

Monoid[String].empty
// res1: String = ""
```

is the same thing as:

```scala
Monoid.apply[String].combine("Hi ", "there")
// res2: String = Hi there

Monoid.apply[String].empty
// res3: String = ""
```

and if we don't need `empty`, then we can do this instead:

```scala
import cats.Semigroup

Semigroup[String].combine("Hi ", "there")
// res4: String = Hi there
```

### Monoid Syntax

Cats provides syntax for `combine` with `|+|`. It technically comes from `Semigroup`, so we need [`cats.syntax.semigroup`](https://typelevel.org/cats/api/cats/syntax/package$$semigroup$):

```scala
import cats.instances.string._ // for Monoid
import cats.syntax.semigroup._ // for |+|

val stringResult = "Hi " |+| "there" |+| Monoid[String].empty
// stringResult: String = Hi there

import cats.instances.int._ // for Monoid

val intResult = 1 |+| 2 |+| Monoid[Int].empty
// intResult: Int = 3
```

### Example

A function that adds: `def add(items: List[Int]): Int`

```scala
def add(items: List[Int]): Int = items.foldLeft(0)(_ + _)

//or

import cats.Monoid
import cats.instances.int._
import cats.syntax.semigroup._

def add(items: List[Int]): Int =
  items.foldLeft(Monoid[Int].empty)(_ |+| _)
```

A function that now adds `List[Option[Int]]`:

```scala
//Make it generic!!

import cats.Monoid
import cats.syntax.semigroup._ // for |+|

def add[A](items: List[A])(implicit monoid: Monoid[A]): A =
  items.foldLeft(monoid.empty)(_ |+| _)
```

Equivalently with [**context bounds**](https://docs.scala-lang.org/tutorials/FAQ/context-bounds.html) syntax:

```scala
def add[A: Monoid](items: List[A]): A =
  items.foldLeft(Monoid[A].empty)(_ |+| _)
```

```scala
import cats.instances.int._ // for Monoid

add(List(1, 2, 3))
// res9: Int = 6

import cats.instances.option._ // for Monoid

add(List(Some(1), None, Some(2), None, Some(3)))
// res10: Option[Int] = Some(6)
```

Now we want to sum of `Order`'s

```scala
case class Order(totalCost: Double, quantity: Double)
```

```scala
implicit val monoid: Monoid[Order] = new Monoid[Order] {
  def combine(o1: Order, o2: Order) =
    Order(
      o1.totalCost + o2.totalCost,
      o1.quantity + o2.quantity
    )

  def empty = Order(0, 0)
}
```