---
layout: page
title: Istio Service Mesh
---

## Concepts

- `RouteRule`
- `DestinationRule` - defines policies to apply to traffic **after** routing, e.g. load balancing, connection pool size, etc.
- `VirtualService` - a set of routing rules which are applied when a host is addressed.

## Cookbook

### Working with objects

List all of the `VirtualService` objects:

    oc get virtualservice.networking.istio.io -n myproject --as=system:admin

### Deploying with Istio

Inject the istio-proxy sidecar container into a Deployment on OpenShift:

    oc apply -f <(istioctl kube-inject -f path/to/deploymentconfig.yml) -n myproject
    
## Observability with Kiali

- A **Workload** maps, for example, to a Deployment in OpenShift

