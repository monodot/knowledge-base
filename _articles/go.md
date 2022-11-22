---
layout: page
title: Go
---

Totally clueless newbie on this one.

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
