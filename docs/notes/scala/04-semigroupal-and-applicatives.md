# Semigroupal and Applicative

Functors and Monads lets us sequence operations using `map` and `flatMap`, which is very useful. But there are some limitations in what computation flow they can do.

For example, form validation. We want all errors, just not the first one. `Either` is great for validation, but it only gets us the first one.

Another example, concurrent evaluation of `Futures`. `map` and `flatMap` can combine Futures, but each one is dependent on the previous one completing.

There are two type classes that enables these use cases:

1. `Semigroupal` composes pairs of context. By using `Semigroupal` and `Functor` we can sequence functions with multiple arguments.
1. `Applicative` extends `Semigroupal` and `Functor`. It provides a way to apply functions to parameters within a context. It also provides the `pure` function we've used before.

## Semigroupal

`Semigroupal` is a type class that allows us to combine contexts. `Semigroupal[F]` allows us to combine `F[A]` and `F[B]` into `F[(A,B)]`.

```scala
trait Semigroupal[F[_]] {
    def product[A,B](fa: F[A], fb: F[B]): F[(A,B)]
}
```

**The order of the two contexts doesn't matter, they are independent.** This makes this more flexible than `flatMap` which has a definite order.

```scala
import cats.Semigroupal
import cats.instances.option._ // for Semigroupal

Semigroupal[Option].product(Some(123), Some("abc"))
// res0: Option[(Int, String)] = Some((123,abc))

Semigroupal[Option].product(None, Some("abc"))
// res1: Option[(Nothing, String)] = None

Semigroupal[Option].product(Some(123), None)
// res2: Option[(Int, Nothing)] = None
```

### Semigroupal With Example Types

**Future**

We can use `Semigroupal` to have concurrent `Futures` zipped together:

```scala
import cats.syntax.apply._ // for mapN

case class Cat(
  name: String,
  yearOfBirth: Int,
  favoriteFoods: List[String]
)

val futureCat = (
  Future("Garfield"),
  Future(1978),
  Future(List("Lasagne"))
).mapN(Cat.apply)

Await.result(futureCat, 1.second)
// res4: Cat = Cat(Garfield,1978,List(Lasagne))
```

**List**

However, `Lists` doesn't get zipped, but rather it performs a cartesian product:

```scala
import cats.Semigroupal
import cats.instances.list._ // for Semigroupal

Semigroupal[List].product(List(1, 2), List(3, 4))
// res5: List[(Int, Int)] = List((1,3), (1,4), (2,3), (2,4))
```

**Either**

We had the example of form validation to collect all errors. So, naturally we expect combining Eithers would give us all the errors. We'd be wrong. It does the same fail fast behavior as `flatMap`:

```scala
import cats.instances.either._ // for Semigroupal

type ErrorOr[A] = Either[Vector[String], A]

Semigroupal[ErrorOr].product(
  Left(Vector("Error 1")),
  Left(Vector("Error 2"))
)
// res7: ErrorOr[(Nothing, Nothing)] = Left(Vector(Error 1))
```

#### Semigroupal with Monads

The reason why `Either` and `List` is weird is because they are both monads. `Monad` extends `Semigroupal` and has a consistent, standard definition of `product` in terms of `map` and `flatMap`. The consistency is needed for  higher level abstractions.

`Future` only works because we create the futures before we use `product`.

**So why semigroupal?** We can create data types that have instances of `Semigroupal` (and `Applicative`) **but not `Monad`**. This enables us to have useful `product` implementations.

##### Exercise: Implement Monad's Product

Implement `product` in terms of `flatMap`:

```scala
import cats.syntax.flatMap._ // for flatMap
import cats.syntax.functor._ // for map
import cats.Monad

def product[M[_]: Monad, A, B](x: M[A], y: M[B]): M[(A, B)] =
    x.flatMap(a => y.map(b => (a, b)))
```

which is the same as:

```scala
def product[M[_]: Monad, A, B](x: M[A], y: M[B]): M[(A, B)] =
    for {
        a <- x
        b <- y
    } yield (a, b)
```

This explains why `List` does not zip and `Either` only takes the first error.

### Validated

Cats provides a data type called `Validated` that has an instance of `Semigroupal` but no instance of `Monad` (which `Either` does). The `product` can then aggregate errors.

```scala
import cats.Semigroupal
import cats.data.Validated
import cats.instances.list._ // for Monoid

type AllErrorsOr[A] = Validated[List[String], A]

Semigroupal[AllErrorsOr].product(
  Validated.invalid(List("Error 1")),
  Validated.invalid(List("Error 2"))
)
// res1: AllErrorsOr[(Nothing, Nothing)] = Invalid(List(Error 1, Error 2))
```

We can use `Validated` to accumulate errors and `Either` to fail fast.

`Validated` isn't a monad, so it doesn't have `flatMap` but it does have `andThen` for something similar. **It isn't called `flatMap` because it doesn't follow all the laws of monads.**

#### Exercise - Form Validation

```
TODO
```

## Apply and Applicative

Semigroupals are not referenced frequently - they provide a subset of the functionality of another type class, **applicative functor** or "applicative" for short.

Cats provide two type classes to model applicatives: 

1. `Apply` which extends `Semigroupal` and `Functor` and adds `ap` method, which applies a parameter to a function with a context. 
1. `Applicative` extends `Apply` and adds `pure` method.

```scala
trait Apply[F[_]] extends Semigroupal[F] with Functor[F] {
  def ap[A, B](ff: F[A => B])(fa: F[A]): F[B]

  def product[A, B](fa: F[A], fb: F[B]): F[(A, B)] =
    ap(map(fa)(a => (b: B) => (a, b)))(fb)
}

trait Applicative[F[_]] extends Apply[F] {
  def pure[A](a: A): F[A]
}
```

* The `ap` method  applies a parameter `fa` to a function `ff` within a context `F[_]`.
* The `product` is defined in terms of `ap` and `map`.

`ap`, `map`, and `product` are tightly bound - each one can be expressed in terms of the other.

`Applicative` introduces `pure` method to create an instance from an unwrapped value.

`Applicative` is to `Apply` as `Monoid` is to `Semigroup`.

#### Excercise - Define `ap`, `map`, and `product` in `Monad` only in `flatMap` and `pure`

From previous Monad seciton, we already defined `map`

```scala
trait Monad[F[_]] extends Applicative[F] with FlatMap[F] {
    def pure[A](a: A): F[A]

    def flatMap[A, B](value: F[A])(func: A => F[B]): F[B]

    def map[A, B](value: F[A])(func: A => B): F[B] =
        flatMap(value)(a => pure(func(a)))
}
```

How do we define `def ap[A, B](ff: F[A => B])(fa: F[A]): F[B]`?

```scala
    def ap[A, B](ff: F[A => B])(fa: F[A]): F[B] =
        for {
            f <- ff
            a <- fa
        } yield f(a)
```

or 

```scala
    def ap[A, B](ff: F[A => B])(fa: F[A]): F[B] =
        ff.flatMap(f => fa.map(f))
```

Putting it together (and pulling `product` definition in `Apply`)

```scala
trait Monad[F[_]] extends Applicative[F] with FlatMap[F] {
    def pure[A](a: A): F[A]

    def flatMap[A, B](value: F[A])(func: A => F[B]): F[B]

    def map[A, B](value: F[A])(func: A => B): F[B] =
        flatMap(value)(a => pure(func(a)))

    def ap[A, B](ff: F[A => B])(fa: F[A]): F[B] =
        flatMap(ff)(f => map(fa)(f))

    def product[A, B](fa: F[A], fb: F[B]): F[(A, B)] =
        ap(map(fa)(a => (b: B) => (a, b)))(fb)
}
```

Replacing `map` and `ap` (need to double check my code here):

```scala
trait Monad[F[_]] extends Applicative[F] with FlatMap[F] {
    def pure[A](a: A): F[A]

    def flatMap[A, B](value: F[A])(func: A => F[B]): F[B]

    def map[A, B](value: F[A])(func: A => B): F[B] =
        flatMap(value)(a => pure(func(a)))

    def ap[A, B](ff: F[A => B])(fa: F[A]): F[B] =
        flatMap(ff)(f => flatMap(fa)(a => pure(f(a))))

    //Yikes
    def product[A, B](fa: F[A], fb: F[B]): F[(A, B)] =
        flatMap(flatMap(fa)(a => pure((b: B) => (a, b))))(f => flatMap(fb)(b => pure(f(b))))
}
```