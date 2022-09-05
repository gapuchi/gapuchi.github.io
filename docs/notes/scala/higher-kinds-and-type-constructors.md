# Higher Kinds and Type Constructors

**Kinds** are like types for types. They describe the number of "holes" (or type parameters) in a type.

Regular types have no "holes" while type constructors have holes that need to be "filled" to produce a type.

* `List` is a type constructor with one hole, takes one parameter
* `List[A]` is a type, produced using a type parameter

This is analogous to functions and values. Functions are "value constructors"

* `math.abs` is a function, takes one parameter
* `math.abs(x)` is a value, produced using a value parameter

In Scala, we declare type constructors using underscores.

```scala
// Declare F using underscores:
def myMethod[F[_]] = {

    // Reference F without underscores:
    val functor = Functor.apply[F]

    // ...
}
```

Analously, we define a function's parameters in its definition and omit them when referring to it.

```scala
// Declare f specifying parameters:
val f = (x: Int) => x * 2

// Reference f without parameters:
val f2 = f andThen f
```

> This is an advanced feature, so in Scala we have to enable support. Either by importing it or adding in the `scalacOptions` in `build.sbt`
>
> ```scala
> import scala.language.higherKinds
> ```
>
> ```scala
> scalacOptions += "-language:higherKinds"
> ```