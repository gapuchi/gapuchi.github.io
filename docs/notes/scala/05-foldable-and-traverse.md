# Foldable and Traverse

* `Foldable` abstracts the `foldLeft` and `foldRight` operations.
* `Traverse` is a higher-level abstraction that uses `Applicative` to iterate with less pain than folding.

## Foldable

`Foldable` type class contains `foldLeft` and `foldRight` methods.

Commonly used in sequences like `Lists`, `Vectors`, and `Streams`.

It is a great use case for `Monoids` and `Eval` monad.

### Folds and Folding

The concept of "folding" - have an **accumulator** value and a **binary function** to combine the accumulator with each element in the sequence.

```scala
def show[A](list: List[A]): String =
  list.foldLeft("nil")((accum, item) => s"$item then $accum")

show(Nil)
// res0: String = nil

show(List(1, 2, 3))
// res1: String = 3 then 2 then 1 then nil
```

We can operate on the sequence in two ways:

1. **left** - beginning to end (`foldLeft`)
1. **right** - end to beginning (`foldRight`)

For example

```scala
List(1, 2, 3).foldLeft(0)(_ + _)
// res2: Int = 6

List(1, 2, 3).foldRight(0)(_ + _)
// res3: Int = 6
```

Addition is associative, so both operations gives us the same result.

It would differ if the binary was non-associative:

```scala
List(1, 2, 3).foldLeft(0)(_ - _)
// res4: Int = -6

List(1, 2, 3).foldRight(0)(_ - _)
// res5: Int = 2
```

### Foldable with Monoids

Cats provides two functions in `Foldable` on top of `foldLeft` that takes advantage of `Monoids`.

* `combineAll` (alias of `fold`) - combines all elements in the sequence (using `combine` in `Monoid`, starting with `empty` in `Monoid`)
* `foldMap` - maps a function over the sequence and combines the results

### Foldable in Cats

`foldLeft` is pretty much what you expect. Not much to add.

`foldRight` is different though. It is defined in terms of `Eval` monad:

```scala
def foldRight[A, B](fa: F[A], lb: Eval[B])(f: (A, Eval[B]) => Eval[B]): Eval[B]
```

We can use `Eval` to keep `foldRight` *stack safe*, even when a data type's `foldRight` default implmentation isn't.

Take `Stream` for example. It isn't stack safe:

```scala
import cats.Eval
import cats.Foldable

def bigData = (1 to 100000).toStream

bigData.foldRight(0L)(_ + _)
// java.lang.StackOverflowError ...
```

Using `Foldable` can make it stack safe

```scala
import cats.instances.stream._ // for Foldable

val eval: Eval[Long] =
  Foldable[Stream].
    foldRight(bigData, Eval.now(0L)) { (num, eval) =>
      eval.map(_ + num)
    }

eval.value
// res7: Long = 5000050000
```

### Exercise - Fold using empty list and `::`

```scala
List(1, 2, 3).foldLeft(List.empty[Int])((a, i) => i :: a)
// res6: List[Int] = List(3, 2, 1)

List(1, 2, 3).foldRight(List.empty[Int])((i, a) => i :: a)
// res7: List[Int] = List(1, 2, 3)
```

### Exercise - Define other methods

`foldLeft` and `foldRight` are general methods that do a lot of things. We can use them to implement other, high-level sequence operations.

```scala
def map[A, B](list: List[A])(func: A => B): List[B] =
    list.foldRight(List.empty[B])((a, agg) => func(a) :: agg)

def flatMap[A, B](list: List[A])(func: A => List[B]): List[B] =
    list.foldRight(List.empty[B])((a, agg) => func(a) ::: agg)

def filter[A](list: List[A])(func: A => Boolean): List[A] =
    list.foldRight(List.empty[A])((a, agg) => if(func(a)) a :: agg else agg)

def sum[A: Monoid](list: List[A]) = 
    list.foldRight(Monoid[A].empty)((a, agg) => a |+| agg)
    // list.foldRight(Monoid[A].empty)(Monoid[A].combine)
```

## Traverse

`Traverse` is a higher-level type class that leverages `Applicatives` to provide a more convenient, lawful, pattern for iteration.