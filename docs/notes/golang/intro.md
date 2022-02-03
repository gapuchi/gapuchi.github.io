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

## Pointers

Pointer
: A pointer holds a memory address of a value.

The type `*T` is a pointer to a `T` value. Its zero value is `nil`.

```go
var p *int
```

The `&` generates a pointer to its operand.

```go
i := 42
p = &i //p is a pointer to 42
```

The `*` operator denotes the pointer's underlying value.

```go
fmt.Println(*p) // read i through the pointer p
*p = 21         // set i through the pointer p
```

This is known as "dereferencing" or "indirecting". 

## Structs

Struct
: A `struct` is a collection of fields.

The struct's fields are accessed using a `.`

```go
type Vertex struct {
	X int
	Y int
}

func main() {
	v := Vertex{1, 2}
	v.X = 4
	fmt.Println(v.X)
}
```

The struct's fields can also be accessed through a struct pointer.

If we want to access field `X` of a struct pointer `p`, we could do `(*p).X`, but that is verbose. So it's simplified to `p.X`.

Struct Literal
: A struct literal represents a newly allocat struct value by listing the values of its fields.

You can list a subset of the fields using `Name:` (and the order doesn't matter).

The `&` prefix returns a pointer to the struct value.

```go
v1 = Vertex{1, 2}  // has type Vertex
v2 = Vertex{X: 1}  // Y:0 is implicit
v3 = Vertex{}      // X:0 and Y:0
p  = &Vertex{1, 2} // has type *Vertex
```

## Arrays

The type `[n]T` is an array of `n` values of type `T`.

So `var a [10]int` is an array of 10 ints. An array cannot be resized, so its okay that the size is part of its type. (Or maybe the other way around? The size is part of the type so an array size cannot be changed?)

## Slices

A slice is a dynamically-sized, flexible view into the elements of an array (which is a fixed size).

The type `[]T` is a slice with elements of type `T`.

A slice is formed by declaring a low and high bound - `a[low  : high]`. It includes the first index and excludes the last one. 

Consider a slice as a reference to an array, it doesn't store any values on its own. If you change a value in a slice, you modify the array and all other slices looking at it.

A slice literal is like an array literal `[3]bool{true, true, false}` but without the length (so `[]bool{true, true, false}`). The slice literal creates the same array and a slice of it (returning the slice).

You can emit the low and high bounds for a slice and let use default low (`0`) and high (length of the array). (e.g. `a[0:]`, `a[:5]`, `a[:]`)

slice length
: The number of elements the slice contains

slice capacity
: The number of elements in the underlying array, starting from the beginning of the slice.

To get the length and capacity, use `len(s)` and `cap(s)`.

You can extend the length of a slice if it has enough capacity. Let's say `s` is a slice of length 1. `s = s[:4]` would extend the length to 4 (assuming the array is at least 4).

The zero value of a slice is `nil`. The length and cap is `0` and has no underlying array.

You can create slices using the built in `make` function. It makes a zeroed array with the given length (and optionally, capacity).

```
a := make([]int, 5)  // len(a)=5
b := make([]int, 0, 5) // len(b)=0, cap(b)=5
```

Slices can container any type, including slices.

You can append to a slice using the built in `append` function.

```
func append(s []T, vs ...T) []T
```

If the backing array is too small, a new one will be created and the slice will point to the new array.

> Does this modify the array? Probably??

## Range

The `range` form of a `for` loop is used to iterate through a slice or a map. The iterator returns two values, the index and a copy of the value at the index.

```go
var pow = []int{1, 2, 4, 8, 16, 32, 64, 128}

for i, v := range pow {
    fmt.Printf("2**%d = %d\n", i, v)
}
```

If you don't need either of the two variables returned by `range`, replace it with an `_`. If you only need the index, drop the second variable.

```go
for _, v := range pow {...}
for i, _ := range pow {...}
for i := range pow {...}
```

## Map 

Map maps keys to values. The zero value of a map is `nil`. A `nil` map has no keys, nor any can be added.

The `make` function returns a map of the given type.

```go
m = make(map[string]Vertex)
m["Bell Labs"] = Vertex{
    40.68433, -74.39967,
}
```

Map literals are like struct literals but require keys.

```go
var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}
```

If the top-level type is just a type name, you don't need to specify the name in the literal

```go
var m = map[string]Vertex{
	"Bell Labs": {40.68433, -74.39967},
	"Google":    {37.42202, -122.08408},
}
```

* Set a value: `m[key] = elem`
* Get a value: `elem = m[key]`
* Delete a key: `delete(m, key)`
* Test if a key is present: `elem, ok = m[key]`. `ok` is a boolean indicating if it is present. `elem` will be the zero value if it is not present.

## Function Values

Functions are values and can be stored in variables and passed as parameters.

```go
func compute(fn func(float64, float64) float64) float64 {
	return fn(3, 4)
}
```

Functions may also be closures, as in referencing variables outside its body.


```go
func adder() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}
```