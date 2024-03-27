---
layout: page
title: Kops
---

Kops is a really nice way to create self-managed Kubernetes clusters, on a public cloud provider.

## Quickstart

```shell
kops get cluster

kops get all

kops get instancegroups
```

## Get kubeconfig for a kops cluster

```shell
export KOPS_STATE_STORE=s3://your-state-store-name

kops get cluster   # list your clusters

kops export kubeconfig --name your-cluster-name.k8s.local --admin   # give the name of the cluster to connect to
```

