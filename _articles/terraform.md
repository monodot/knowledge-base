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

#### Convert a map of usernames into a for_each input

```
{for user in var.terminal_users : user.username => user}
```

### Outputs

#### Output a map of maps

```
# e.g.:
# app_url = {
#   "mydave" = "https://trcgotestjoe.example.com"
#   "myjoe"  = "https://trcgotestsusan.example.com"
# }
output "app_url" {
  value = {
    for key, stack in module.my_custom_module : key => stack.stacks.url
  }
}
```

#### Output a map of maps


```hcl
# e.g.:
# email_fields = {
#   "joe@example.com" = {
#     "url"         = "https://trcgotestjoe.example.com"
#     "username"    = "joe"
#     "password"    = "hiyaaa"
#     "webterminal" = "https://example.com"
#   }
output "email_fields" {
  value = {
    for user in var.my_users : user.email => {
      "url"         = module.my_custom_module[user.id].stacks.url
      "username"    = user.username
      "password"    = user.password
      "webterminal" = "https://example.com"
    }
  }
}
```

#### Output an entire submodule's output

```hcl
output "stacks" {
  value     = module.my_custom_module
  sensitive = true
}
