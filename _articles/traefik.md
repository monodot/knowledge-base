---
layout: page
title: Traefik
---

Traefik is a reverse proxy and load balancer that is often used as an ingress controller for Kubernetes. It can also be used as a standalone reverse proxy for other services.

## Middleware

Middlewares are the way that Traefik can modify requests and responses. They can be used to add headers, redirect requests, and more.

### Example Middleware: redirect HTTP to HTTPS

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: redirect-https
spec:
  redirectScheme:
    scheme: https
    permanent: true
```

Then attach the Middleware onto an Ingress like this:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.middlewares: default-redirect-https@kubernetescrd
    # ...
```