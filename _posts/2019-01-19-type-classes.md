---
layout: post
title:  "Scala With Cats - Type Classes"
date:   2019-01-19
categories: [scala, cats]
---

I decided to take a crack at learning the [Cats library for Scala](https://books.underscore.io/scala-with-cats/scala-with-cats.html). This serves as reference for my notes. You'll notice that contents will mirror the book, and pieces of it will be very similar if not identical to it as well. Again, this serves as my notes and will just contain the pieces that I think are important, not obvious, or a good reminder.

# Type Classes

A lot of tools provided by Cats are in the form of *type classes*, a programming pattern that allows use to add additional functionality to existing libraries. This avoids inheritance and changing the libraries' source code.

## Anatomy of a Type Class

*Type class pattern* has three components:

* The **type class**
* The **instances** for particular types
* The **interface methods** exposed

### Type Class

A *type class* is an interface or API that represents some functionality we want to implement. In Cats, a type class is represented by **a trait with at least one type parameter**

> Ex: We want the functionality to serialize to JSON

```scala
//Type class
trait JsonWriter[A] {
    def write(value: A): Json
}
```

### Type Class Instances

The *instances* of a type class provide implementations for the types we care about.

In Scala, we create concrete implementations of the type class and make them `implicit`.

```scala
final case class Person(name: String, email: String)

object JsonWriterInstances {
    //For string
    implicit val stringWriter: JsonWriter[String] =
        new JsonWriter[String] {
            def write(value: String): Json =
            JsString(value)
        }


    //For Person
    implicit val personWriter: JsonWriter[Person] =
        new JsonWriter[Person] {
            def write(value: Person): Json =
            JsObject(Map(
                "name" -> JsString(value.name),
                "email" -> JsString(value.email)
            ))
        }

    //etc.
}
```

### Type Class Interface

A *type class interface* is any functionality that we expose, taking an instance of the type class as an `implicit` paramter.

This is done two ways, **interface objects** and **interface syntax**.

#### Interface Objects

One form of an interface is to place methods in a singleton object.

```scala
object Json {
    def toJson[A](value: A)(implicit w: JsonWriter[A]): Json =
        w.write(value)
}
```

and to use the interface:

```scala
import JsonWriterInstances._

Json.toJson(Person("Dave", "dave@example.com"))
```

#### Interface Syntax

Another way to create an interface is to use *extension methods*. (This is referred to as *syntax* in Cats).

```scala
object JsonSyntax {
    implicit class JsonWriterOps[A](value: A) {
        def toJson(implicit w: JsonWriter[A]): Json =
            w.write(value)
    }
}
```

and to use the interface:

```scala
import JsonWriterInstances._
import JsonSyntax._

Person("Dave", "dave@example.com").toJson
```

> This took me a second to understand what was happening here, as I am not familiar with *extension methods*. The way I understand it, `Person` doesn't have a `toJson` method, so the Scala compiler looks for a way for it to have it. By using the `implicit class`, the compiler passes in the instance of `Person` as part of the constructor and creates an instance of `JsonWriterOps`. With this implicit, `Person` can call `toJson`. 

# Conclusion

That's basically it! Using **type classes**, we can define functionality and it's implementations for specific types. It's a pretty cool pattern to implement.

The main advantage that is apparent to me is the ability to have **on demand functionality.** We can serialize `Person` in different ways for different parts of a program. This on demand feature has definite benefits over *inheritance*, which requires implementation of functionality at the time of writing code, or implementing functionality in the libraries iteself.

Implicits make type class implementations look very clean as well. The only potential issue I see is that the use of *extension methods* may not be apparent, if that interface is used. 

The purpose of implicits hasn't been clear to me, in general, since it seemed to only make the declaration of the parameter passed less clear when looking at the code. However, I can see how it can be useful as long as there is a standard practice of when it is used, rather than making parameters implicity arbitrarily. In Cats, they set the standard of type classes to use implicits. However, we can also implement type classes without using implicits. It would be the same as the examle above, with the only change being to explicitly pass in the *type class instance* to the *type class interface*.