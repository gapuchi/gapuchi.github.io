# Functors 

In layman's terms, a functor is anything with a `map` function. The `map` can be thought as a means to change all values in a structure, without changing the structure.

```scala
List(1, 2, 3).map(n => n + 1)
// res0: List[Int] = List(2, 3, 4)

Some(1).map(n => n * 2)
// res1: Option[Int] = Some(2)

Option.empty[Int].map(n => n * 2)
// res2: Option[Int] = None
```

Because it doesn't change, we can chain calls

```scala
Right(12)
    .map(n => n + 1)
    .map(n => n + 1)
    .map(n => n + 1)
    .map(n => n * 3)
    .map(n => n - 4)
// res3: scala.util.Either[Nothing,Int] = Right(41)
```

`List`, `Option`, `Either` all have eager evaluations. But `map` doesn't have to be. All it is a mean to sequence of operations.

## Example: Futures

`Future` is a functor that sequences asynchronous computations, by executing each one as the previous one completes.

```scala
import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._

val future: Future[String] =
  Future(123).
    map(n => n + 1).
    map(n => n * 2).
    map(n => n + "!")

Await.result(future, 1.second)
// res3: String = 248!
```

**Note:** Future aren't referentially transparent. They are computed and results are cached. This gives us non functional behavior when wrapping side effects in `Future`'s.

```scala
import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._
import scala.util.Random

val future1 = {
  val r = new Random(0L)

  val x = Future(r.nextInt) //nextInt is a side effect

  for {
    a <- x
    b <- x
  } yield (a, b)
}

//should be the same as

val future2 = {
  val r = new Random(0L)

  for {
    a <- Future(r.nextInt) //Replaced x with its value
    b <- Future(r.nextInt)
  } yield (a, b)
}

val result1 = Await.result(future1, 1.second)
// result1: (Int, Int) = (-1155484576,-1155484576)

val result2 = Await.result(future2, 1.second)
// result2: (Int, Int) = (-1155484576,-723955400)
```

## Definition of a Functor

A **functor** is a type `F[A]` that has a `map` operation of the type of `(A => B) => F[B]`.

```scala
package cats

import scala.language.higherKinds

trait Functor[F[_]] {
  def map[A, B](fa: F[A])(f: A => B): F[B]
}
```

It should adhere to two laws:

```scala
// Identity
fa.map(a => a) == fa

Composition
fa.map(g(f(_))) == fa.map(f).map(g)
```

This gives the property that functors will behavior doesn't change whether we do multiple operations or combine the operations into a single function and then apply it once.

## Exercise

Write a `Functor` for the following binary tree data type.

```scala
sealed trait Tree[+A]

final case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]

final case class Leaf[A](value: A) extends Tree[A]
```

```scala
import cats.Functor

implicit val branchFunctor = new Functor[Branch] {
  def map[A, B](branch: Branch[A])(f: A => B): Branch[B] = 
    Branch(
      branch.left.map(f),
      branch.right.map(f)
    )
}

implicit val leafFunctor = new Functor[Leaf] {
  def map[A, B](leaf: Leaf[A])(f: A => B): Leaf[B] = 
    Leaf(leaf.value.map(f))
}
```

This would not work! Because of

```scala
branch.left.map(f),
branch.right.map(f)
```

`branch.left` and `branch.right` are of type `Tree[A]`, for which we do not have a `Functor defined. Instead the solution would look like:

```scala
import cats.Functor

implicit val treeFunctor = new Functor[Tree] {
  def map[A,B](tree: Tree[A])(func: A => B): Tree[B] =
    tree match {
      case Branch(left, right) => Branch(map(left)(func), map(right)(func))
      case Leaf(value) => Leaf(func(value))
    }
}
```

We recursively call `map` on a branch above.

However, below won't run:

```scala
Branch(Leaf(10), Leaf(20)).map(_ * 2)
// <console>:42: error: value map is not a member of wrapper.Branch[Int]
//        Branch(Leaf(10), Leaf(20)).map(_ * 2)
//    
```

This is because of an invariance problem. The compiler knows a `Functor` instance for `Tree` but not for `Branch` or `Leaf`. We can add smart constructors to solve this:

```scala
object Tree {
  def branch[A](left: Tree[A], right: Tree[A]): Tree[A] = Branch(left, right)

  def leaf[A](value: A): Tree[A] = Leaf(left, right)
}
```

Now we can use `Functor`:

```scala
Tree.leaf(100).map(_ * 2)
// res10: wrapper.Tree[Int] = Leaf(200)

Tree.branch(Tree.leaf(10), Tree.leaf(20)).map(_ * 2)
// res11: wrapper.Tree[Int] = Branch(Leaf(20),Leaf(40))
```

This works because `leaf` and `branch` method is defined to return `Tree`.

```
// TODO Contramap and Invariant Functors
```