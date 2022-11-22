---
layout: page
title: Google Cloud
---

## Authenticating

### Application Default Credentials (ADC)

Google's own client libraries look for credentials in:

- `GOOGLE_APPLICATION_CREDENTIALS` environment variable

## gcloud cookbook

## Projects and zones

List all zones

```
gcloud compute zones list
```

List all Projects:

```
gcloud projects list
```

## Kubernetes clusters

List all clusters:

```
gcloud container clusters list --project my-corporate-department
```

Log on to a cluster:

```
gcloud container clusters get-credentials my-pet-cluster --zone us-central1-c --project my-corporate-department
```

## Container registry

Authenticate to the container registry with podman: [^1]

```bash
gcloud auth print-access-token | podman login -u oauth2accesstoken --password-stdin XX.gcr.io
```

[^1]: https://stackoverflow.com/questions/63790529/authenticate-to-google-container-registry-with-podman
