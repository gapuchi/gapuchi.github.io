# Monads

In layman's terms, a functor is anything with a `flatMap` function.

> A **monad** is a mechanism for sequencing computations.

But doesn't a **functor** sequence computations? It allows us do perform computations while ignoring some "complications". The thing is, it can handles complications at the beginning. If more complications occur, it cannot handle that.

> Complications here meaning the complications of a data type. E.g. how do we apply a function to an Option? We have to get the value, apply it, and return an Option wrapping it. If it is None, return None.

So with functors, we can change `Option[A]` with `A => B` and get `Option[B]`. What happens if a "complication" occurs, i.e. with `A => Option[B]`? Then we get `Option[Option[B]]`.

This is where monads come in. The `flapMap` method allows us to specify what to apply next, accouting for the complication. 

The `flatMap` method of `Option` takes intermediate `Options` to account. Same with the `flatMap` method of `List`, etc.

This "complication" makes more sense if we look at the `Future` monad. `Future` is a monad that sequences computations without having to worry that they are asynchronous.

```scala
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._

def doSomethingLongRunning: Future[Int] = ???
def doSomethingElseLongRunning: Future[Int] = ???

def doSomethingVeryLongRunning: Future[Int] =
  for {
    result1 <- doSomethingLongRunning
    result2 <- doSomethingElseLongRunning
  } yield result1 + result2
```

The `flatMap` takes care of all the complexity of thread pools, scheudlers, and that garbage.

The above runs the computations in sequence. We can think of it as `Future[A] flatMap A => Future[B]` giving us `Future[B]`. We can also do parallel, but thats for another time.

## Definition of a Monad

A monad of constructor type `F[_]` has:

* An operation `pure` of type `A => F[A]`
* An operation `flatMap` of type `(F[A], A=> F[B]) = F[B]`

```scala
import scala.language.higherKinds

trait Monad[F[_]] {
  def pure[A](value: A): F[A]

  def flatMap[A, B](value: F[A])(func: A => F[B]): F[B]
}
```

Monads must obey certain laws:

Left Identity. Calling `pure` and then transforming with `func` is the same as calling `func`.

```scala
pure(a).flatMap(func) == func(a)
```

Right identity. Passing `pure` to `flatMap` is the same as doing nothing.

```scala
m.flatMap(pure) == m
```

Associativity.

```scala
m.flatMap(f).flatMap(g) == m.flatMap(x => f(x).flatMap(g))
```

### Exercise - A monad is also a functor

Define `map` using `flatMap` and `pure`:

```scala
import scala.language.higherKinds

trait Monad[F[_]] {
  def pure[A](a: A): F[A]

  def flatMap[A, B](value: F[A])(func: A => F[B]): F[B]

  def map[A, B](value: F[A])(func: A => B): F[B] =
    flatMap(value)(a => pure(func(a)))
}
```

## The Identity Monad

We can define methods that are abstracted over different monads:

```scala
import scala.language.higherKinds
import cats.Monad
import cats.syntax.functor._ // for map
import cats.syntax.flatMap._ // for flatMap

def sumSquare[F[_]: Monad](a: F[Int], b: F[Int]): F[Int] =
  for {
    x <- a
    y <- b
  } yield x*x + y*y
```

This works with `Options` and `Lists` but not plain old values:

```
sumSquare(3,4) //This won't work! An F doesn't exist such that F[Int] equals Int
```

It'd be nice if we could define a method that would handle monadic and non-monadic types. Cats provdes the `Id` type to achieve this.

```scala
import cats.Id

sumSquare(3 : Id[Int], 4 : Id[Int])
// res2: cats.Id[Int] = 25
```

We're casting an `Int` to `Id[Int]`, what is going on? Here is the definition of `Id`

```scala
package cats

type Id[A] = A
```

Id is actually a type alias. We can cast any value to its corresponding `Id`. Cats provides instances for various type classes for `Id`, including `Functor` and `Monad`.

### Exercise - Implement Id Monad Instance

Implement `pure`, `map`, and `flatMap` for `Id`

```scala
  val monad = new Monad[Id] {

    def pure[A](a: A): Id[A] = a

    def flatMap[A, B](value: Id[A])(func: A => Id[B]): Id[B] = 
        func(a)

    def map[A, B](value: Id[A])(func: A => B): Id[B] = 
        func(a)
  }
```

> **`map` can be defined with `pure` and `flatMap`. How does that reduce to `func(a)`?**
>
> ```
> flatMap(value)(a => pure(func(a)))
> flatMap(value)(a => func(a))
> flatMap(value)(func)
> func(value)
> ```

> **Why is `flatMap` and `map` the same?**
>
> Functors and Monads are used for sequencing computations ignoring some kind of complications. In the case of `Id`, there is no complication, so making both of them identical.

## The Either Monad

In Scala 2.11 and prior, `Either` wasn't really considered a monad because it didn't have `map` and `flatMap`. Starting with 2.12, `Either` became *right biased* and a monad.

Meaning `map` and `flatMap` were applied to `Right`. If it was `Left` then no-op.

It is used a lot for error handling

```scala
type Result[A] = Either[Throwable, A]
```

`Throwable` can be very general, we can make it more explicit:

```scala
sealed trait LoginError extends Product with Serializable

final case class UserNotFound(username: String)
  extends LoginError

final case class PasswordIncorrect(username: String)
  extends LoginError

case object UnexpectedError extends LoginError

case class User(username: String, password: String)

type LoginResult = Either[LoginError, User]
```

This gives us the ability to discretely handle specific errors.

## The Eval Monad

`cats.Eval` is a monad that allows us to abstract over different models of evaluation. Three models that cats provides, eager, lazy, and memoized.

- eager is done immediately
- lazy is done when value is accessed
- memoized is done on first accessed and then cached

`vals` are eager and memoized

```scala
val x = {
  println("Computing X")
  math.random
}
// Computing X
// x: Double = 0.013533499657218728

x // first access
// res0: Double = 0.013533499657218728

x // second access
// res1: Double = 0.013533499657218728
```

`defs` are lazy and not memoized

```scala
def y = {
  println("Computing Y")
  math.random
}
// y: Double

y // first access
// Computing Y
// res2: Double = 0.5548281126990907

y // second access
// Computing Y
// res3: Double = 0.7681777032036599
```

`lazy vals` are lazy and memoized.

```scala
lazy val z = {
  println("Computing Z")
  math.random
}
// z: Double = <lazy>

z // first access
// Computing Z
// res4: Double = 0.45707125364871903

z // second access
// res5: Double = 0.45707125364871903
```

`Eval` has three subtypes: `Now`, `Later`, and `Always`. To draw comparisons:

|Scala|Cats|Properties|
|---|---|---|
|`val`|`Now`|eager, memoized|
|`lazy val`|`Later`|lazy, memoized|
|`def`|`Always`|lazy, not memoized|

We access the value with the `value` method.

The `map` and `flatMap` methods add computations to a chain. In this case, it is a list of functions, that aren't run until `value` method is invoked.

```scala
val greeting = Eval.
  always { println("Step 1"); "Hello" }.
  map { str => println("Step 2"); s"$str world" }
// greeting: cats.Eval[String] = cats.Eval$$anon$8@79ddd73b

greeting.value
// Step 1
// Step 2
// res15: String = Hello world
```

The mapping functions are always called lazily on demand (`def`)

```scala
val ans = for {
  a <- Eval.now { println("Calculating A"); 40 }
  b <- Eval.always { println("Calculating B"); 2 }
} yield {
  println("Adding A and B")
  a + b
}
// Calculating A
// ans: cats.Eval[Int] = cats.Eval$$anon$8@12da1eee

ans.value // first access
// Calculating B
// Adding A and B
// res16: Int = 42

ans.value // second access
// Calculating B
// Adding A and B
// res17: Int = 42
```

`Eval` has a `memoize` method to memoize a change of computations.

```scala
val saying = Eval.
  always { println("Step 1"); "The cat" }.
  map { str => println("Step 2"); s"$str sat on" }.
  memoize.
  map { str => println("Step 3"); s"$str the mat" }
// saying: cats.Eval[String] = cats.Eval$$anon$8@159a20cc

saying.value // first access
// Step 1
// Step 2
// Step 3
// res18: String = The cat sat on the mat

saying.value // second access
// Step 3
// res19: String = The cat sat on the mat
```

```
TODO

- Trampolining and Eval.defer
- Writer Monad
- Reader Monad
- State Monad
```

> Why do we need `pure`?

## The Writer Monad

The writer monad allows us to carry a log along with a computation.

-  A use case for this is multi-threaded computations. We can keep track of logs for separate threads without worrying about them interleaving.

The `Writer[W, A]` has two values, a log of type `W` and a result of type `A`.

Writer has some convenience methods.

`pure` syntax - to create with only result. We need to have `Monoid[W]` so we can create an empty log (`W`).

```scala
type Logged[A] = Writer[Vector[String], A]

123.pure[Logged]
// res2: Logged[Int] = WriterT((Vector(),123))
```

`tell` syntax - to create with only log.

```scala
Vector("msg1", "msg2", "msg3").tell
// res3: cats.data.Writer[scala.collection.immutable.Vector[String],Unit] = WriterT((Vector(msg1, msg2, msg3),()))
```

`Writer.apply` or `writer` syntax if we have both.

```scala
val a = Writer(Vector("msg1", "msg2", "msg3"), 123)
// a: cats.data.WriterT[cats.Id,scala.collection.immutable.Vector[String],Int] = WriterT((Vector(msg1, msg2, msg3),123))

val b = 123.writer(Vector("msg1", "msg2", "msg3"))
// b: cats.data.Writer[scala.collection.immutable.Vector[String],Int] = WriterT((Vector(msg1, msg2, msg3),123))
```

`value` to get result.
`written` to get logs.

```scala
val aResult: Int =
  a.value
// aResult: Int = 123

val aLog: Vector[String] =
  a.written
// aLog: Vector[String] = Vector(msg1, msg2, msg3)
```

`run` to get both.

```scala
val (log, result) = b.run
// log: scala.collection.immutable.Vector[String] = Vector(msg1, msg2, msg3)
// result: Int = 123
```

### Composing and Transforming

`map` only operates on the result

`flatMap` appends the logs (so it needs `Semigroup[W]`) and with the computed results.

> This is an example of how `flatMap` handles complexity. We use `flatMap` to apply a function to our result giving us another `Writer`. One with a log and the result. `flatMap` here handles this by taking in the new result and taking the **old log** and appending the **new log**. That is handled out of the box.

`mapWritten` transforms the logs.

```scala
val writer2 = writer1.mapWritten(_.map(_.toUpperCase))
// writer2: cats.data.WriterT[cats.Id,scala.collection.immutable.Vector[String],Int] = WriterT((Vector(A, B, C, X, Y, Z),42))
```

`bimap` transforms both log and result, taking in two functions.

`mapBoth` transforms both log and result, taking in one function with two arguments.

```scala
val writer3 = writer1.bimap(
  log => log.map(_.toUpperCase),
  res => res * 100
)
// writer3: cats.data.WriterT[cats.Id,scala.collection.immutable.Vector[String],Int] = WriterT((Vector(A, B, C, X, Y, Z),4200))

writer3.run
// res6: cats.Id[(scala.collection.immutable.Vector[String], Int)] = (Vector(A, B, C, X, Y, Z),4200)

val writer4 = writer1.mapBoth { (log, res) =>
  val log2 = log.map(_ + "!")
  val res2 = res * 1000
  (log2, res2)
}
// writer4: cats.data.WriterT[cats.Id,scala.collection.immutable.Vector[String],Int] = WriterT((Vector(a!, b!, c!, x!, y!, z!),42000))

writer4.run
// res7: cats.Id[(scala.collection.immutable.Vector[String], Int)] = (Vector(a!, b!, c!, x!, y!, z!),42000)
```

`result` clears the logs.

`swap` swaps the log and result.

### Exercise - factorial

Let's say we have a slow `factorial` that logs.

```scala
def slowly[A](body: => A) =
  try body finally Thread.sleep(100)

def factorial(n: Int): Int = {
  val ans = slowly(if(n == 0) 1 else n * factorial(n - 1))
  println(s"fact $n $ans")
  ans
}
```

If we have multi-threaded application, the logs will get interleaved.

Rewrite `factorial` to capture the log messages.

```scala
type Logged[A] = Writer[Vector[String], A]

def slowly[A](body: => A) =
  try body finally Thread.sleep(100)

def factorial(n: Int): Logged[Int] = {
 
    for {
      ans <-  if (n==0)
                1.pure[Logged]
              else
                slowly(factorial(n - 1).map(_ * n))
      _ <- Vector(s"fact $n $ans").tell
    } yield ans
}
```