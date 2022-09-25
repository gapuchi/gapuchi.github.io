# Ad-hoc Polymorphism in Cats

Taking a deeper look into how ad-hoc polymorphism works with Scala Cats.

The concept of polymorphism is the ability for a code that can work with multiple types.

> TODO What does ad-hoc mean here?

This can be done in many different ways.

## Inheritance

> TODO Look up Type System

With inheritance, polymorphism is achieved with subclasses.

The OO way. Subclassing.

Java supports inheritance.

We can declare an interface or class with the desired functionality.

> Functionality vs Behavior
>
> Functionality - The function
> Behavior  - The implementation of the function

```java
interface Animal {
    public String speak();
}
```

We can have many forms of `speak` by implementing the interface.

```java
class Dog implements Animal {
    public String speak() {
        return "woof";
    }
}

class Cat implements Animal {
    public String speak() {
        return "woof";
    }
}
```

We can also override implemented behavior by subclassing

```java
class BigDog extends Dog {
    public String speak() {
        return "WOOF";
    }
}
```

This overrides the previous behavior.

The downside

## Trait Objects

