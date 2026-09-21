---
layout: page
title: gcx
---

The Grafana CLI.

## Contexts and setup

Temporary credential:

```sh
gcx login my-stack --server https://my-stack.grafana.net
```

Long-lived credential:

```
gcx login my-grafana --server https://your-instance.grafana.net --token glsa_xxx --yes
```

## Knowledge Graph

### Count the number of Service entities per Environment

```sh
gcx kg entities list --type Service --since 1h --limit 0 --jq '[.[] | .scope.env] | group_by(.) | map({env: .[0], services: length})'
```

### Count the number of Pod entities in each Environment

```sh
gcx kg entities list --type Pod --since 1h --limit 0 --jq '[.[] | .scope.env] | group_by(.) | map({env: .[0], pods: length})'
```

### See the values for asserts_env and deployment_environment values in a stack

```sh
# 
gcx metrics labels --label asserts_env --no-color
# Traces
gcx metrics labels --label deployment_environment --no-color
```

### View KG's scopes

```sh
gcx kg meta scopes
# Scope values (env, site, namespace):
#   env: abcd12-cluster, none, production, unknown
#   site: ap-south-1, eu-west-1, none, us-east-2
#   namespace: ecommerce-prod, internal-services, kube-system, none, util-ecommerce-prod
```

