---
layout: page
title: "OpenShift: Authenticate to Docker Hub"
---

Authenticate to Docker Hub so that you can get higher pull rate limits.

```
oc create secret docker-registry docker-hub \
  --docker-server=docker.io \
  --docker-username=youhoo \
  --docker-password=yoursecret

oc secrets link default docker-hub --for=pull,mount
oc secrets link builder docker-hub --for=pull,mount
```