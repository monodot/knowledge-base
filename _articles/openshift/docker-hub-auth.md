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

If you still get _ImagePullBackOff_ and all that crap:

- Find out which ServiceAccount your app is using: `oc get deploy -o yaml` then look for `serviceAccount` and make sure you've linked the Secret to the correct ServiceAccount.
- Check that the secret has been linked to the _ServiceAccount_ correctly: `oc get sa default -o yaml` - the registry secret should be listed in the list of secrets and _imagePullSecrets_.

