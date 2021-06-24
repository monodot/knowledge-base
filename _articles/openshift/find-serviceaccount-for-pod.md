---
layout: page
title: "OpenShift: Find which ServiceAccount is running a Pod"
---

Find out which ServiceAccount is running a Pod, so that you can give special permissions to the ServiceAccount if they are needed:

```
oc get pod argocd-redis-74845f8775-bt5jd -o json | jq '.spec.serviceAccount'
```

Should return the name of the ServiceAccount:

```
"default"
```