# A Tour of Go

## Packages, Variables, Functions

### Packages

A Go program is made of **packages**.

Programs start running in package `main`.

[Convention] Package name is the same as the last element of the import path. For example, `"math/rand"` package comprises of fiels that begin with the statement `package rand`.

Below is an example `main` package which uses packages with import paths `"fmt"` and `"math/rand"`

```go
package main

import (
    "fmt"
    "math/rand"
)

func main() {
    fmt.Println("My favorite number is", rand.Intn(10))
}
```

### Import

You can group imports into a parenthesized, "factored" import statement.

You could also write multiple import statements, like:

```go
import "fmt"
import "math"
```

[Convention] It is good style to use the factored import statement.

### Exported Names

When importing a package, you can only refer to its exported names. Any unexported names are not accessible from outside the package.

A name is exported if it begins with a capital letter. e.g. `Pizza`. `pizza` is unexported.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Println(math.pi) //Fails because pi, not Pi
}
```

### Function

```go
func add(x int, y int) int {
    return x + y
}
```

Note type goes after the variable name. 

See also: [Go's Declaration Syntax](https://go.dev/blog/declaration-syntax).

If consecutive function parameters share a type, you can omit the type from all except the last.

```go
func add(x, y int) int {
    return x + y
}
```

A function can return any number of results

```go
func swap(x, y string) (string, string) {
    return y, x
}
```

A function's returned values can be named. If they are, they are treated as variables defined in the top of the function.

A `return` statement without arguments returns the named return values. This is know as a **naked** return.

```go
func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return
}
```

### Variables

`var` declares a list of variables, with the type being at the end.

It can be used at a package or a function level.

```go
package main

import "fmt"

var c, python, java bool

func main() {
    var i int
    fmt.Println(i, c, python, java)
}

```

A `var` declaration can include initializers, one per variable. If an initializer is present, the type can be omitted.

```go
var i, j int = 1, 2
var c, python, java = true, false, "no!"
```

Inside a function, the `:=` short assignment statement can be used instead of `var`, with implicit type.

Outside a function, the `:=` is not available because every statement must start with a keyword (`var`, `func`, etc).

### Zero Value

Variables declared without an explicit initial value are given their *zero value*. These are:

* `0` for numeric types.
* `false` for boolean type
* `""` for strings.

### Type Conversion

The expression `T(v)` converts the value `v` to the type `T`.

```go
i := 42
f := float64(i)
u := uint(f)
```

### Type Inference

When declaring a variable without specifying an explicit type, the variable's type is inferred from the value on the right hand side.

### Constants

Constants are declared using the `const` keyword. It cannot be declared using the `:=` syntax.

## Flow Control

### For

Go has only one looping construct, `for`.

It's basically like Java's `for` loop. Init statement, condition, and post statement.

```go
for i := 0; i < 10; i++ {
    sum += i
}
```

> You don't need `()` surrounding the three components and `{}` are always required.

The init and post statements are optional.

```go
for ; sum < 1000; {
	sum += sum
}
```

You can drop the semicolons, and by magic, it becomes a `while` loop.

```go
for sum < 1000 {
	sum += sum
}
```

You can drop the condition and it loops forever.

```go
for {
	sum += sum
}
```

### If

Like `for`, the expression need not be surround by `()` and `{}` are required.

```go
if x < 0 {
	return sqrt(-x) + "i"
}
```

`if` statement can start with a short statement to execute before the condition.

```go
if v := math.Pow(x, n); v < lim {
	return v
}
```

Variables declared by the statement are only in scope until the end of the `if`.

Variables declared by the statement are also available inside any of the `else` blocks.

```go
if v := math.Pow(x, n); v < lim {
	return v
} else {
	fmt.Printf("%g >= %g\n", v, lim)
}
```

### Switch

The `switch` is like in Java, a nicer way to write `if/else` statements. Unlike Java, it **only runs the first matching case**. The cases also do not need to be constants.

```go
switch os := runtime.GOOS; os {
case "darwin":
    fmt.Println("OS X.")
case "linux":
    fmt.Println("Linux.")
default:
    fmt.Printf("%s.\n", os)
}
```

It evaluates top to bottom, and does not evaluate other cases once a matching case is found.

You can write a switch statement without a condition and it'll be interpreted as `switch true {...`. You can use this to write complex `if/else` statements.

```go
switch {
case t.Hour() < 12:
    fmt.Println("Good morning!")
case t.Hour() < 17:
    fmt.Println("Good afternoon.")
default:
    fmt.Println("Good evening.")
}
```

### Defer

A `defer` statement delays the execution of a function until the surrounding function returns.

```go
func main() {
	defer fmt.Println("world")

	fmt.Println("hello")
}
```

> In Java, we can consider this to be `finally`. It's useful for cleaning up after a function. The nice thing about this is that you can declare the clean up function as soon as it is relevant instead of at the end. Nicer organizaiton.

Couple traits:

1. A deferred function’s arguments are evaluated when the defer statement is evaluated. If a variable in the defer statement is changed after the defer statement, it won't reflect in the call of the defer function.
1. Deferred function calls are executed in Last In First Out order after the surrounding function returns.
1. Deferred functions may read and assign to the returning function’s named return values. (Useful for errors.)

```go
func c() (i int) {
    defer func() { i++ }()
    return 1
}
```

This will return `2`.

Panic
: A built-in function that stops the normal flow of control and begins *panicking*. If a function invokes `panic`, everything stops, any deferred functions are executed normally, and returns to the caller. The caller would see function as if it was a `panic`. Panic bubbles up until all the functions in the goroutine have returned. Program then crashes.

Recover
: A built-in function that regains control of a panicking goroutine. It is only useful in deferred functions. A call to recover will return `Nil` if the function isn't panicking and will return the value passed to the `panic` if the function was panicking and then resume normally.

```go
package main

import "fmt"

func main() {
    f()
    fmt.Println("Returned normally from f.")
}

func f() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Recovered in f", r)
        }
    }()
    fmt.Println("Calling g.")
    g(0)
    fmt.Println("Returned normally from g.")
}

func g(i int) {
    if i > 3 {
        fmt.Println("Panicking!")
        panic(fmt.Sprintf("%v", i))
    }
    defer fmt.Println("Defer in g", i)
    fmt.Println("Printing in g", i)
    g(i + 1)
}
```

Would output

```
Calling g.
Printing in g 0
Printing in g 1
Printing in g 2
Printing in g 3
Panicking!
Defer in g 3
Defer in g 2
Defer in g 1
Defer in g 0
Recovered in f 4
Returned normally from f.
```

> The convention in the Go libraries is that even when a package uses panic internally, its external API still presents explicit error return values.
