---
layout: page
title: Buildah
---

A container image building tool.

## Cookbook

## Build image for multiple architectures and then push to Google Artifact Registry

```shell
buildah build --jobs=2 \
    --platform=linux/arm64,linux/amd64,linux/arm/v7 \
    --manifest myapp-manifest .

# Authenticate buildah to Google Cloud
gcloud auth print-access-token | buildah login -u oauth2accesstoken --password-stdin us-central1-docker.pkg.dev

buildah manifest push --all myapp-manifest \
    docker://us-central1-docker.pkg.dev/my-google-project/myapp/myapp:1.0
```

