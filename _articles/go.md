---
layout: page
title: Go
---

Totally clueless newbie on this one.

## Syntax speedrun

### Pointers

- `*` is used to declare a pointer.
- `&` is used to get the address of a variable you're pointing to, or want to point to.

```go
var x int = 1
var y = &x // y holds variable x's memory address

var y *int = &x
```

### Variables

```go
var x int = 1
var x = 1
x := 1
```

### Functions

```go
func learnNamedReturns(x, y int) (z int) {
    //...
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

_"Cannot find package github.com/.../... in any of ...."_ when running `go get`:

- Try `GO111MODULE=on` first.

[^1]: https://go.dev/doc/tutorial/add-a-test
