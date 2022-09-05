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

Monoids must obey certain laws:

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

There are data types where there is no sensible `empty` element. For example:

* Positive integers data type
* Non-empty lists data type

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


## Exercise

Write the code for `def add(items: List[Int]): Int`

```scala
def add(items: List[Int]): Int =
    items.foldLeft(0)(_ + _)
```

Or with Monoids, (we don't really need to do it this way.)

```scala
import cats.Monoid
import cats.instances.int._    // for Monoid
import cats.syntax.semigroup._ // for |+|

def add(items: List[Int]): Int =
    items.foldLeft(Monoid[Int].empty)(_ |+| _)
```

Write the code for `def add(items: List[Option[Int]]): Int`


```scala
import cats.Monoid
import cats.instances.int._    // for Monoid
import cats.syntax.semigroup._ // for |+|

def add(items: List[A])(implicit monoid: Monoid[A]): A =
    items.foldLeft(monoid.empty)(_ |+| _)
```

or use Scala's *context bound* syntax:

```scala
def add[A: Monoid](items: List[A]): A =
  items.foldLeft(Monoid[A].empty)(_ |+| _)
```

With this implementation, we can use to add elements of a `List[Int]` and `List[Option[Int]]`

```scala
import cats.instances.int._ // for Monoid

add(List(1,2,3))
// res9: Int = 6

import cats.instances.option._ // for Monoid

add(List(Some(1), None, Some(2), None, Some(3)))
// res10: Option[Int] = Some(6)
```

This will fail if the `List` contained only `Some` values, since the inferred value of the list would be `List[Some[Int]]` not `List[Option[Int]]` and we don't have a Monoid for `Some[A]`.

Now we want to add up `Orders`

```scala
case class Order(totalCost: Double, quantity: Double)
```

How can we use `add`?

```scala
implicit val orderMonoid = new Monoid[Order] {
    def combine(o1: Order, o2: Order) =
    Order(
      o1.totalCost + o2.totalCost,
      o1.quantity + o2.quantity
    )

  def empty = Order(0, 0)
}
```
