---
layout: page
title: Terraform
---

## Cookbook

### Collections

#### Convert a map to a multi-line string with line delimiters

Convert a map of usernames and passwords into a multiline string in the format `username:password`..

First you'll need to define the variable in a `variables.tf` file (You can't define variables within Terraform console):

```terraform
terminal_users = [
  {
    username = "dave"
    password = "dav381919"
  },
  {
    username = "lucy"
    password = "lucy123211"
  },
]
```

Then:

```
join("\r\n", [for user in var.terminal_users : "${user.username}:${user.password}"])
```

#### Convert a map of usernames into a space-separated list

```
join(" ", [for user in var.terminal_users : user.username])
```
