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

