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

### Looping 

#### A poor round-robin

- Use the `element` function to get the element at a given index in a list
- Use the `index` function to get the index of a given key in a map
- Use the `values` function to get a list of values from a map

This allows us to loop around input structures and do a "round-robin" of the values. For example:

- assign each server to a network, from a known list of networks
- assign each user to a different server, from a known list of servers

```hcl
module "some_module" {
  for_each = { for idx, user in keys(var.servers) : server => var.servers[server] }

  # Now let's pick a network for this server by doing a round-robin of the networks,
  # using the index of the server in the map (0, 1, 2, 3, 4, 5, etc...)
  # Assuming that module.vpc.networks returns something like:
  # [
  #   {
  #     name = "network-01"
  #   },
  #   {
  #     name = "network-02"
  #   },
  # ]
  # And the var.servers map looks like:
  # {
  #   "server-01" = {
  #     ...
  #   },
  #   "server-02" = {
  #     ...
  #   },
  # }

  # We use 'each.key' to get the current key in the map
  # We then use this to get the index of the current key in the map
  # And then use that index to get the element at that index, in another list
  # The 'element' function returns the element at the given index in a list
  # (and wraps around to the beginning of the list if the index is greater than
  # the length of the list) - e.g. 0, 1, 2, 3, 0, 1, 2, 3...
  # e.g. "network-01", "network-02", etc.
  server_network_name = element(
    values(module.vpc.networks),
    index(keys(var.servers), each.key) 
  ).name
}
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
