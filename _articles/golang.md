---
layout: page
title: Go (language)
---

Totally clueless newbie on this one.

## Syntax speedrun

### Variables and consts

```go
// Assigning values to variables 
var y int = 1  // most verbose way
var y = 1      // assumes an int type, because 1 is an int literal
x := 1         // this style can be used only within a function

const x = 10 // an untyped constant declaration 
const typedX int = 10 // can only be assigned where an int is expected 
```

### Pointers

- `*` is used to declare a pointer.
- `&` is used to get the address of a variable you're pointing to, or want to point to.

```go
var x int = 1
var y = &x // y holds variable x's memory address

var y *int = &x
```

### Functions

What does a function look like in Go?

#### Named returns

```go
func learnNamedReturns(x, y int) (z int) {
    z = x * y
    return
}
```

- `z` is the named return; simple assignment to it will return it.
- `int` is the return type.
- We just need to use `return` to return the named return.

#### Methods
Or this function, which is actually called a **method**, because it has a **receiver**, making it a function that belongs to a type:

```go
func (c *Client) NewStack(stack *CreateStackInput) (int64, error) {
    // ...
}
```

- `c *Client` is the <i>receiver</i>. It's like `this` in JavaScript.
- `NewStack` is the method name.
- `stack *CreateStackInput` is the argument.
- `(int64, error)` is the return type.

In Go, methods can be defined on either values or pointers:

- If a method is defined on a pointer (i.e. with `*`), it can modify the value that it points to.
- If a method is defined on a value, it receives a copy of the value, so it cannot modify the original value.

#### Receivers

Here is a complete piece of code that shows how a receiver is used in a method:

```go
package main

import "fmt"

type Rectangle struct {
    Width  float64
    Height float64
}

// This method calculates the area of a Rectangle.
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

func main() {
    rect := Rectangle{Width: 5.0, Height: 3.0}
    area := rect.Area()
    fmt.Println("Area of the rectangle:", area)
}
```

## Testing

Ending a file's name with `_test.go` tells the `go test` command that this file contains test functions. [^1]

To run tests:

```bash
go test

# to see all of the tests and their results
go test -v 

```

## Troubleshooting

### Cannot find package

_"Cannot find package github.com/.../... in any of ...."_ when running `go get`:

- Try `GO111MODULE=on` first.

### VS Code: "Could not import..." and red underlines

- You've opened a Git repo in VS Code and are trying to open one of many child Go projects in that repo. VS Code / `gopls` is getting confused.
- In VS Code, just open the child project in its own workspace.
- Or, open your Git repo as usual, and then choose File &rarr; Add Folder to Workspace, select your module's folder, and all will magically work!

[^1]: https://go.dev/doc/tutorial/add-a-test
