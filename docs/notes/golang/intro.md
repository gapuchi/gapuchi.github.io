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

## If

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