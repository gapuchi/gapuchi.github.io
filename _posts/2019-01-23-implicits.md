---
layout: post
title: "Scala With Cats - Implicits"
date: 2019-01-23 10:30:00 -0900
categories: [scala, cats]
---

Continuing my reading of [Scala With Cats](https://books.underscore.io/scala-with-cats/scala-with-cats.html#working-with-implicits).

Couple things to know when using implicits

## Packaging Implicits

Any definition marked `implicit` in Scala must be placed inside an object or trait rather than top level. In a [previous post]({{ site.baseurl }}{% post_url 2019-01-19-type-classes %}), we created an object called `JsonWriterInstances` to hold our *type class instances*. Another approach we could have taken is to place these instances in the *companion object* of `JsonWriter`. This is significant in Scala because it bring in the concept of *implicit scope*.

## Implicit Scope

```scala
Json.toJson("A string!")
```

In the example above, the compiler will look for an instance type of `JsonWriter[String]` in the *implicit scope* at the call site. This includes:

* local or inherited definitions
* imported definitions
* definitions in the companion object of the **type class or parameter type** (in our example, `JsonWrite` and `String` respectively)

If more than one definition is found, the compiler will fail with "ambiguous implicit values" error.

In Cats, we can package type class instances in 4 ways:

| By placing them in | Bring into scope by |
| --- | --- |
| an object such as `JsonWriterInstances` | Importing |
| a trait | Inheritance |
| the companion object of the type class | Already in scope |
| the companion object of the parameter type | Already in scope |

## Recursive Implicit Resolution

The compiler can combine implicit definitions when searching for instances, making type classes with implicits a powerful tool.

We can actually define implicits in two ways by defining:

1. concrete instances as `implicit val`'s of the required type
1. `implicit` methods to construct instances from other type class instances.

Why would we need to construct instances rather than defining concrete instances? Let's look back at `JsonWriter` type class. Say we want to use `Option` with it. We would need an instance of the type `JsonWriter[Option[A]]`. Meaning we would need to define one for every `A`:

```scala
implicit val optionPersonWriter: JsonWriter[Option[Int]] = ???

implicit val optionPersonWriter: JsonWriter[Option[Person]] = ???

// etc
```

giving us a total of two new instances for every type we introduce. Luckily we can abstract the code.

```scala
implicit def optionWriter[A]
    (implicit writer: JsonWriter[A]): JsonWriter[Option[A]] =
        new JsonWriter[Option[A]] {
            def write(option: Option[A]): Json =
                option match {
                    case Some(aValue) => writer.write(aValue)
                    case None         => JsNull
                }
        }
```

Now when a compiler sees this:

```scala
Json.toJson(Option("A string"))
```

it searches for an implicit `JsonWriter[Option[String]]`. If finds the method returning `JsonWriter[Option[A]]`

```scala
Json.toJson(Option("A string"))(optionWriter[String])
```

and recursively searches for a `JsonWriter[String]` to use as a parameter to `optionWriter`.

```scala
Json.toJson(Option("A string"))(optionWriter(stringWriter))
```

With this, implicit resolution becomes a search throughout the whole domain of possible combinations of implicit definitions to find the right combination to give us a type class definition of the right type.

### Note: Implicit Conversion

When creating a type class instance constructor using `implicit def`, be sure to mark all parameters with `implicit`, so the compiler can fill these in during resolution. If not marked, it creates another programming pattern called *implicit conversion* which is frowned upon in Scala.

## Conclusion

This really brings out the advantages of implicits. Implicit resolution is a powerful tool that lets the compiler automatically resolve parameters by automatically constructing the appropriate type. In my [previous post]({{ site.baseurl }}{% post_url 2019-01-19-type-classes %}), I mentioned that type classes can be implemented without `implicit`s. However, implicits are key if we want to utilize a powerful tool such as implicit resolution.
