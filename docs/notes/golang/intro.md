# A Tour of Go

## Packages

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

## Import

You can group imports into a parenthesized, "factored" import statement.

You could also write multiple import statements, like:

```go
import "fmt"
import "math"
```

[Convention] It is good style to use the factored import statement.

## Exported Names

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

## Function

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