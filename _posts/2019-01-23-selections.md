---
layout: post
title: "Scala With Cats - Selection"
date: 2019-01-23 16:30:00 -0900
categories: [scala, cats]
---

Two questions:

* How does types and subtypes relate?

> If we create an instance of `JsonWriter[Option[Int]]`, will `Json.toJson(Some(1))` use this instance?

* How do we choose between type classes when there is more than one available?

## Variance

We can add *variance* to the type parameter for a type class.

`B` is a *subtype* of `A` if we can use a value of type `B` anywhere `A` is expected.

The idea of *covariance* and *contravariance* is introduced when using variance with type constructors.

### Covariance

Covariance means `F[B]` is a subtype of `F[A]` if `B` is a subtype of `A`. Many collections like `List` or `Option` are covariant.

```scala
trait List[+A]
trait Option[+A]
```

With covariant, something like this is possible:

```scala
sealed trait Shape
case class Circle(radius: Double) extends Shape

val circles: List[Circle] = ???
val shapes: List[Shape] = circles
```

### Contravariance

Contravariance means `F[A]` is a subtyp of `F[B]` if `B` is a subtype of `A`. Our example `JsonWriter` is an example of this.

```scala
trait JsonWriter[-A] {
  def write(value: A): Json
}
```

In order to understand this, lets an example with `Circle`, `Shape`, and our `JsonWriter`:

```scala
val shape: Shape = ???
val circle: Circle = ???

val shapeWriter: JsonWriter[Shape] = ???
val circleWriter: JsonWriter[Circle] = ???

def format[A](value: A, writer: JsonWriter[A]): Json =
  writer.write(value)
```

Which combinations makes sense? Obviously, passing a `Circle` value and `JsonWriter[Circle]` makes sense.

But what about passing a `Shape` value and `JsonWriter[Circle]`? That would not work because not all shapes are circles. This means **we cannot substitute `JsonWriter[Shape]` with `JsonWriter[Circle]`**.

But what about passing a `Circle` value and `JsonWriter[Shape]`? That is fine because a `Circle` is a `Shape` and can be treated as such. This means **we can substitute `JsonWriter[Circle]` with `JsonWriter[Shape]`**.

From this we learned that `JsonWriter[Shape]` is a subtype of `JsonWriter[Circle]`, because we can replace any `JsonWriter[Circle]` with `JsonWriter[Shape]`.

#### Co vs Contra

So how do we tell if a type parameter is covariant or contravariant? It depends on what we are doing with that type.

It is contravariant if we are performing actions on instances of the type. In `JsonWriter`, it writes a value of the type parameter.

It is covariant if we are reading from instances of the type. `List` and `Option` have covariant type parameters because they are collections. Their only functionality is to read the value of the instance of the type parameters.

Given this, we can say **parameters types are contravariant and return types are covariant for functions**. To understand this, let's make a trait `Function1[P,R]`, which holds a function that takes a single parameter of type `P` and returns a value of type `R`. Using variance, the proper declaration would be:

```scala
trait Function1[-P, +R] {
    def exec(param: P): R
}
```

So, `Function1[Shape, Circle]` is a subtype of `Function1[Circle, Shape]`. Does this make sense? Let's test this theory.

```scala
//Redefining Shape
sealte trait Shape {
    def area: Double
}
//Redefining Circle
case class Circle(radius: Double) extends Shape {
    def area = Math.pi * radius * radius
}

val func1: Function1[Shape, Circle] = new Function {
    //Takes in a shape and returns a circle with the same area
    def func(param: Shape): Circle = {
        val r = Math.sqrt(param.area/Math.pi)
        Circle(r)
    }
}

val func2: Function1[Circle, Shape] = new Function {
    //Creates a new instance of Shape with area defined
    //as the same as the radius of the circle.
    def func(param: Circle): Shape = {
        new Shape {
            def area = param.radius
        }
    }
}
```

Now let's say we do:

```scala
val shape = new Shape {
    def area = 4
}

val r = func1.exec(shape).radius
```

The compiler won't complain, because `func1` take in a shape and returns a circle, which we can call radius on. Cool. Can we replace `func1` with `func2`?

```scala
val r = func2.exec(shape).radius
```

No, no we cannot. Two issues. First, we passed in an object that wasn't `Circle` as a parameter. So `param.radius` won't compile. Second, we called `radius` on the return value of the `exec` method, but the returned Shape object doesn't have a radius method. So `Function1[Circle, Shape]` is not a subtype of `Function1[Shape, Circle]`.

How about the other way around?

```scala
val a = func2.exec(Circle(2)).area
```

This is a valid statement. `func2` takes in a circle and returns a Shape with an area function that returns the same value as the circle's area. Cool. Now let's try to substitute with `func1`.

```scala
val a = func1.exec(Circle(2)).area
```

Does this work? Yes! `func1` is now taking in a `Circle`, which is fine because it treating it as a shape. Anything done on `Shape` can be done to `Circle`. The `exec` method now returns an instance of `Circle`, which we can call `area` method on, because anything `Shape` can do, `Circle` can do it as well. So `Function1[Shape, Circle]` is a subtype of `Function1[Circle, Shape]`.

If `B` is a subtype of `A` and `Function1[A,B]` is a subtype of `Function1[B,A]`, then the first parameter type is contravariant and the second is covariant. Hence `Function1[-P,+R]`.

### Invariance

```scala
trait F[A]
```

`F[A]` and `F[B]` are never subtypes of each other, no matter the relationship between `A` and `B`.

## Controlling Selection

When the compiler looks for an implicit, it looks for one matching the type *or subtype*. We can use variance to control somewhat how implicits are selected.

This brings up two questions. Take the example:

```scala
sealed trait A
final case object B extends A
final case object C extends A
```

1. Will an instance defined on a supertype if available? E.g. we have one defined for `A`, can we use it if we're looking one for `B` or `C`?
1. Will an instance of subtype be selected over the supertype? E.g. we have defined `A` and `B`, will `B` be selected over `A`?

Both can't happen:

| Type Class Variance | Invariant | Covariant | Contravariant |
| --- | --- | --- | --- |
| Supertype instance used? | No | No | Yes |
More specific type preferred? | No | Yes | No |

Cats prefers invariant, to allow more control. This does bring up the scenario where if we have value of type `Some[Int]`, a type class instance of `Option` won't be used. This can be solved by having something like `Some(1): Option[Int]` or using "smart  constructors" like `Option.apply`, `Option.empty`, `some`, and `none`.
