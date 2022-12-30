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

## Troubleshooting

This error is seen in `kubectl get events`: _"Failed to Attach 1 network endpoint(s) (NEG "k8s1-4362fb64-default-myapp-4000-7414754d" in zone "us-central1-c"): googleapi: Error 400: Invalid value for field 'resource.ipAddress': '10.32.1.5'. Specified IP address 10.32.1.5 doesn't belong to the (sub)network default or to the instance gke-mycluster-w-default-pool-fff0000-zzzz., invalid"_

- If you visit the Google Cloud web console, browse to your Cluster &rarr; Ingress &rarr; Backend services &rarr; (Service for your app) &rarr; Backends, you will see that there are `0 of 0` healthy services. Your Network Endpoint Group (NEG) is empty.
- **Cause:** You are trying to expose a service outside the cluster using **container-native load balancing** but your Kubernetes cluster is not "VPC-native".
  - Container-native load balancing is enabled when you add an annotation `cloud.google.com/neg: '{"ingress": true}'` to a Service.
  - **Solution:** [Create a VPC-native cluster][vpcnative]. 
  - Thanks to [this awesome GitHub issue][ghissue].

[vpcnative]: https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
[ghissue]: https://github.com/kubernetes/ingress-gce/issues/1463

[^1]: https://stackoverflow.com/questions/63790529/authenticate-to-google-container-registry-with-podman