---
layout: page
title: Terraform
---

## Learnings

### Providers and shared modules

- **A module intended to be called by one or more other modules must not contain any _provider_ blocks.**
- **Provider configurations can be defined only in a root Terraform module.**
- If a module contains its own _provider_ configurations, it is considered "legacy", and is prevented from being used with the _count_, _for_each_ and _depends_on_ arguments.

## Development tricks

### Set up mitmproxy to debug requests

If you're working with a provider that doesn't provide an easy way to see the requests it's making, then install a proxy (like **mitmproxy**) and route all your requests through it:

```
mitmproxy

sudo cp ~/.mitmproxy/mitmproxy-ca-cert.cer /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust

export HTTP_PROXY=localhost:8080 && export HTTPS_PROXY=localhost:8080

terraform apply ...
```

#### A note about error timings

- If some errors happen in a Terraform job, they will be logged **at the end** of the process.
- But the actual time of the error **can be much earlier** than the time that the error is logged.
- This can be confusing if you're troubleshooting a problem, and you need to check some corresponding system logs (e.g. the proxy logs, as configured above) for the specific time/date of the error.
- Solution: enable debug logging `TF_LOG=DEBUG`, which should show the **original** timestamp of the error, so you can correlate this with whatever other system logs you're using to investigate.

### Deploying only parts of a configuration

To deploy only certain parts of a Terraform configuration, use the `-target` flag, e.g.:

```bash
terraform apply -target module.my_module

# With a resource defined as: `resource "local_file" "foo" { }`
terraform apply -target=local_file.foo
```

### Debugging a provider with CLI overrides

If you want to debug a provider, you can download its source code and then tell Terraform to use your local copy by creating an overrides file:

For example:

```shell
git clone https://github.com/grafana/terraform-provider-grafana
cd terraform-provider-grafana
git checkout v1.35.0
go build

cat > ~/.terraformrc <<EOF
provider_installation {
  dev_overrides {
    "grafana/grafana" = "/home/tdonohue/repos/terraform-provider-grafana"
  }
}
EOF

cd path/to/your/terraform/config
terraform apply
```

### Debugging a provider with Delve

Activate the provider's debug mode (check the provider's source code for the correct environment variable to set) and start a debugging session:

```shell
cd ~/repos/terraform-provider-grafana
$HOME/go/bin/dlv debug . -- --debug

(dlv) break theMethodYouWantToBreakOn
(dlv) continue

# This will print a line like TF_REATTACH_PROVIDERS...
```

And then, in another window, paste the env var declaration and run Terraform as normal:

```
TF_REATTACH_PROVIDERS=...
terraform apply
```


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
```
