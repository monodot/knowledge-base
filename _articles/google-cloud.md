---
layout: page
title: Google Cloud
---

{% include toc.html %}

## Authenticating

### Application Default Credentials (ADC)

ADC is a mechanism for applications to automatically obtain credentials to call Google APIs.

Google's own client libraries look for credentials in:

- `GOOGLE_APPLICATION_CREDENTIALS` environment variable

### Workload Identity

Workload Identity is a feature of GKE that allows you to associate a Kubernetes Service Account with a Google Cloud Service Account. This allows you to use the Google Cloud Service Account to authenticate to Google Cloud APIs from within a Kubernetes cluster.

#### Example using imperative gcloud commands

Here's an example that configures a Kubernetes Service Account with Workload Identity so that a Pod can access a Google Cloud Storage bucket:

```shell
export KUBE_SA_NAME=myapp-sa
export KUBE_NAMESPACE=mynamespace
export GCP_SA_NAME=mycluster-workload-identity
export GCP_PROJECT=your-google-cloud-project
export GCP_BUCKET_NAME_DATA=your-loki-data-bucket

kubectl create serviceaccount ${KUBE_SA_NAME} --namespace ${KUBE_NAMESPACE}

gcloud iam service-accounts create ${GCP_SA_NAME} \
    --project=${GCP_PROJECT}

# Grant admin access to the bucket to the Google Cloud service account
gsutil iam ch serviceAccount:${GCP_SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com:objectAdmin gs://${GCP_BUCKET_NAME_DATA}

gcloud iam service-accounts add-iam-policy-binding ${GCP_SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${GCP_PROJECT}.svc.id.goog[${KUBE_NAMESPACE}/${KUBE_SA_NAME}]"

kubectl annotate serviceaccount ${KUBE_SA_NAME} \
    --namespace ${KUBE_NAMESPACE} \
    iam.gke.io/gcp-service-account=${GCP_SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com

kubectl -n ${KUBE_NAMESPACE} set sa deploy/myapp ${KUBE_SA_NAME}
```

#### Adding IAM role using Terraform

This resource links an IAM service account with a Kubernetes service account so that a Pod can access a Google Cloud Storage bucket:

```hcl
resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.kubernetes_service_account}]"
}
```

Verify that the target IAM policy binding on the target IAM service account is correct:

```shell
$ gcloud iam service-accounts get-iam-policy my-service-account-h5cp@my-google-project.iam.gserviceaccount.com
bindings:
- members:
  - serviceAccount:my-google-project.svc.id.goog[default/webterminal]
  role: roles/iam.workloadIdentityUser
etag: abcdefabcdef
version: 1
```

Might also need to use the `google_storage_bucket_iam_member` resource to grant the IAM role to the service account:

```hcl
resource "google_storage_bucket_iam_member" "bucket_admin" {
  bucket = "my-bucket-of-files"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account}"
}
```

You will also need to add the annotation to the Kubernetes service account used by your app, e.g.:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: webterminal
  annotations:
    iam.gke.io/gcp-service-account: my-service-account-h5cp@my-google-project.iam.gserviceaccount.com
```


## Cookbook

### Projects and zones

List all zones

```
gcloud compute zones list
```

List all Projects:

```
gcloud projects list
```

### Networking

#### Delete all Network Endpoint Groups in a VPC

Because sometimes you might have Network Endpoint Groups hanging around after you've deleted a Kubernetes cluster:

```shell
gcloud compute network-endpoint-groups list \
  --filter="network:($VPC_NAME)" \
  --format="csv[no-heading](name,zone)" \
  | while IFS=, read -r name zone ; do 
  echo gcloud compute network-endpoint-groups delete $name --zone $zone --quiet; 
  done
```

### IAM 

- A **principal** is a user (e.g. a Google Account) (`user:`), a service account (`serviceAccount:`), a group (`group:`), Workspace account or domain (`domain:`). Each principal has a unique identifier, which is typically an email address.
- A **role** is a collection of permissions, which define what can be done on a resource.
- A **resource** is a Google Cloud resource, such as a project, folder, or organisation.
- A **role binding** is a combination of a principal(s) and a role, which grants the role to the principal(s).
- An **allow policy** is a collection of role bindings.

It is also absolutely bonkers. I mean it's fairly powerful, but I feel like I could still be learning this in 100 years' time.

#### List all roles

This lists all of the roles that you can assign to a user or service account:

```
gcloud iam roles list
```

#### List the roles held by a principal/service account (at a Project level)

This _needlessly-complex_ command lists all of the roles that a user has at a project level. This allows us to see what roles a user has in a Google Cloud Project.

```shell
gcloud projects get-iam-policy my-project \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:theserviceaccount@my-project.iam.gserviceaccount.com"
```

Should return something like this:

```
ROLE
roles/artifactregistry.reader
roles/artifactregistry.writer
```

#### Add a role to a principal/service account (at a Project level)

If you want to give a role in a project to a service account, you can do this:

```shell
gcloud projects add-iam-policy my-project \
  --member="serviceAccount:my-service-account@my-project.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.reader"
```

You can list the roles available with `gcloud iam roles list --format="value(name)"`.

#### Grant a role to a principal

```
gcloud projects add-iam-policy-binding my-project --member user:
```

### Google Kubernetes Engine (GKE)

#### List all clusters

```
gcloud container clusters list --project my-corporate-department
```

#### Log on to a cluster

```
gcloud container clusters get-credentials my-pet-cluster --zone us-central1-c --project my-corporate-department
```

### Artifact Registry

#### Authenticate to the container registry with podman

From [^1]

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

Cannot deploy an image from a private Artifact Registry onto a GKE cluster - constant "ImagePullBackOff" error:

- You need to grant the following OAuth scope to the nodes (in the cluster's node pool) when you create the cluster: `https://www.googleapis.com/auth/devstorage.read_only`
- If your cluster has node pools which use a custom Service Account, then you will need to grant the Role `roles/artifactregistry.reader` to the custom Service Account.
  - Get the Service Account ID: `gcloud container node-pools describe default-pool --zone us-central1 --cluster my-gke-cluster --project my-gcp-project --format="value(config.serviceAccount)"`
  - Grant the Role: `gcloud artifacts repositories add-iam-policy-binding my-artifact-repo --location=us --member $SERVICE_ACCOUNT --role roles/artifactregistry.reader --project my-gcp-project`

When trying to add an Ingress with SSL to a VPC-native GKE cluster, with Google-managed SSL, the endpoint cannot be reached in a browser:

- If the Ingress has been created with annotation `kubernetes.io/ingress.allow-http: "false"` then the SSL configuration must be successful, otherwise the Ingress will be inaccessible, even when trying to directly access the IP of the Ingress. In other words: check that you've configured SSL correctly.
- Diagnosis:
  - Check the status of the `Ingress` object - it might say something like _"error running load balancer syncing routine: loadbalancer xxxxx does not exist: invalid configuration: both HTTP and HTTPS are disabled (kubernetes.io/ingress.allow-http is false and there is no valid TLS configuration); your Ingress will not be able to serve any traffic"_
  - Check the status of the `ManagedCertificate` - `kubectl -n default describe managedcertificate mycert` - in the `status` field, it should show the reason why the certificate failed to be provisioned. For example: `FailedNotVisible` means that the DNS entry couldn't be reached.
- Solution:
  - If you don't have a `ManagedCertificate`, create one.
  - Check that you can reach the hostname given in your `ManagedCertificate`. If it's configured through Google DNS, then make sure an appropriate A-record exists for the hostname.

[vpcnative]: https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
[ghissue]: https://github.com/kubernetes/ingress-gce/issues/1463

[^1]: https://stackoverflow.com/questions/63790529/authenticate-to-google-container-registry-with-podman