---
layout: page
title: Loki
---

Loki is a time series database for strings; written in Go, and inspired by Prometheus. It's suited to aggregating and searching logs.

{% include toc.html %}

## Fundamentals

- Loki is a time-series database for strings. [^1]
- Loki exposes an HTTP API for pushing, querying and tailing log data.
- Loki stores logs as strings exactly how they were created, and indexes them using _labels_.
- Loki is usually combined with _agents_ such as Promtail, which turn log lines into _streams_ and push them to the Loki HTTP API.
- You can combine Loki with Prometheus _Alertmanager_ to send send notifications when things happen.

### Terminology

- Logs are grouped into **streams**, which are indexed with **labels**.
- A **log stream** is a combination of a **log source + a unique set of labels**.
  - A set of log entries with the same labels applied, and grouped together.
- **Tenant** is a user in Loki. 
  - Loki runs in multi-tenant mode by default. This means that requests and data from tenant A are isolated from tenant B. [^3]
  - To disable multi-tenancy, set `auth_enabled: false` in the config file.
  - 

### Use cases

Examples of the types of data that you might put into Loki:

- Nginx logs
- IIS logs
- Cloud-native app logs
- Application logs (e.g. financial trades)
- Linux server logs (systemd journal)
- Kubernetes logs (via service discovery)
- Docker container logs


## Getting started

### Running Loki 2.6.1 and Promtail with podman-compose on Fedora

```
git clone https://github.com/monodot/grafana-demos
cd grafana-demos/loki-basic
podman-compose up -d
```

## Clients

How to get data into Loki:

- Promtail
- Grafana Agent
- Log4J
- Logstash

## Configuration

### Storage

Loki has a few different storage options.

- Object storage

- File system storage

| *Data type* | *Storage type* | *Info* |
| ----------- | -------------- | ------ |
| Chunk store | `filesystem` | ... |
| Chunk | Bigtable | ... |


### Retention

- Retention in Loki is achieved through the Table Manager or the Compactor. [^2]
  - For the Table Manager, you need to configure a TTL on your object store (e.g. Minio, AWS S3)
  - For the Compactor, retention is only supported when using boltdb-shipper (a.k.a. single-store Loki)
- Loki doesn't delete old chunk stores, unless you're using the `filesystem` chunk store type.
- To enable Loki to auto-delete old data, you need to configure a **retention duration**.

The BoltDB Shipper includes a component called the Compactor:

- If you're using the **boltdb-shipper** store, you can configure the _Compactor_ to perform retention.
- If you're using the _Compactor_, you don't need to also configure the _Table Manager_.

Some sample log output from the compactor:

```
level=info ts=2022-10-26T10:53:33.938957622Z caller=table.go:297 table-name=index_19291 msg="starting compaction of dbs"
level=info ts=2022-10-26T10:53:33.939192532Z caller=table.go:307 table-name=index_19291 msg="using compactor-1666779684.gz as seed file"
level=info ts=2022-10-26T10:53:34.896614531Z caller=util.go:116 table-name=index_19291 file-name=compactor-1666779684.gz msg="downloaded file" total_time=957.203888ms
level=info ts=2022-10-26T10:53:34.905190561Z caller=util.go:116 table-name=index_19291 file-name=loki-658f65f74-ktrb8-1666624278963029120-1666780200.gz msg="downloaded file" total_time=4.612842ms
level=info ts=2022-10-26T10:53:34.910608485Z caller=util.go:116 table-name=index_19291 file-name=loki-658f65f74-ktrb8-1666624278963029120-1666779300.gz msg="downloaded file" total_time=12.883266ms
level=info ts=2022-10-26T10:53:34.917018576Z caller=util.go:116 table-name=index_19291 file-name=loki-658f65f74-ktrb8-1666624278963029120-1666781006.gz msg="downloaded file" total_time=13.412156ms
level=info ts=2022-10-26T10:53:34.919466949Z caller=util.go:116 table-name=index_19291 file-name=loki-658f65f74-ktrb8-1666624278963029120-1666780721.gz msg="downloaded file" total_time=18.015007ms
level=info ts=2022-10-26T10:53:35.184416949Z caller=util.go:136 msg="compressing the file" src=/loki/compactor/index_19291/compactor-1666779684.gz dest=/loki/compactor/index_19291/compactor-1666779684.gz.gz
level=info ts=2022-10-26T10:53:36.230758123Z caller=index_set.go:281 table-name=index_19291 msg="removing source db files from storage" count=5
level=info ts=2022-10-26T10:53:36.239174627Z caller=compactor.go:557 msg="finished compacting table" table-name=index_19291
```

#### Using Google Cloud Storage as a backend

To use a Google Cloud Storage Bucket to store chunks, you need to provide authentication, which is usually either one of these:

- Application Default Credentials (ADC)

- Workload Identity

#### Using Google Application Default Credentials (ADC)

Create an IAM Service Account and grant it object admin (basically read+write) on the bucket(s) you're using. This example for Grafana Enterprise Logs (which uses 2 buckets):

```
export SA_NAME=my-pet-cluster-gel-admin

gcloud iam service-accounts create ${SA_NAME} \
            --display-name="My GEL Cluster Storage service account"

gsutil iam ch serviceAccount:${SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com:objectAdmin gs://${GCP_BUCKET_NAME_DATA}

gsutil iam ch serviceAccount:${SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com:objectAdmin gs://${GCP_BUCKET_NAME_ADMIN}
```

Generate a private key which GEL can use to authenticate as the service account, and use the sGoogle Cloud Storage API:

```
gcloud iam service-accounts keys create ./sa-private-key.json \
  --iam-account=${SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com

export GCLOUD_SERVICE_ACCOUNT_JSON=$(cat sa-private-key.json | tr -d '\n')
```

Finally, make the JSON available to Loki:

- Create a secret which contains the JSON representation of the Service Account key generated above

- Mount the secret inside the Loki pod

- Set an environment variable `GOOGLE_APPLICATION_CREDENTIALS=/path/to/mounted/key.json`

Extra step: Additionally, if deploying Grafana Enterprise Logs, add the GCLOUD_SERVICE_ACCOUNT_JSON value to the key `admin_client.storage.gcs.service_account` in your Loki config YAML.

#### Using GKE Workload Identity

If you don't want to create a key for your IAM Service Account and mount it as a secret, use GKE's Workload Identity feature instead. The Google Cloud SDK inside Loki will then implicitly authenticate to Google Cloud Storage, using credentials granted by the Kubernetes Service Account assigned to the Loki Pod.

Instructions derived from <https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity>:

```
export KUBE_SA_NAME=loki-sa
export NAMESPACE=yourkkubenamespace
export GCP_SA_NAME=loki-workload-identity
export GCP_PROJECT=your-google-cloud-projecte
export GCP_BUCKET_NAME_DATA=your-loki-data-bucket

kubectl create serviceaccount ${KUBE_SA_NAME} --namespace ${NAMESPACE}

gcloud iam service-accounts create ${GCP_SA_NAME} \
    --project=${GCP_PROJECT}

gsutil iam ch serviceAccount:${GCP_SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com:objectAdmin gs://${GCP_BUCKET_NAME_DATA}

gcloud iam service-accounts add-iam-policy-binding ${GCP_SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${GCP_PROJECT}.svc.id.goog[${NAMESPACE}/${KUBE_SA_NAME}]"

kubectl annotate serviceaccount ${KUBE_SA_NAME} \
    --namespace ${NAMESPACE} \
    iam.gke.io/gcp-service-account=${GCP_SA_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com

kubectl -n ${NAMESPACE} set sa sts/ge-logs ${KUBE_SA_NAME}
```

## Architecture

### Components

For optional scalability, Loki components are grouped into **write** and **read** components and can be started using the `-target=write|read` CLI option:

| *Component* | *Included in target* | *What it does* |
| ----------- | ------ | -------------- |
| compactor | read | |
| distributor | write | |
| ingester | write | Also includes the WAL (Write-Ahead Log). |
| ingester-querier | read | |
| querier | read | |
| query-frontend | read | Merges query results together. |
| query-scheduler | read | |
| ruler | read | Continually evaluates a set of queries, and performs an action based on the result, i.e. alerting rules and recording rules. Useful for sending alerts, or precomputing expressions that are computationally expensive to run. |
| usage-report | read | aka Table Manager |
| gateway | TBC | ... |
| memcached | TBC | Memcached, memcached-frontend, memcached-index-queries |
| gel-admin-api | TBC | ... |

### Scalability

<!-- - Prefer object stores (e.g. S3) as a backend. -->


## Using Loki

### Multitenancy

- X-Scope-OrgID


### Labels and indexing

- Don't add lots of labels unless you really need them.

- Prefer labels that describe the **topology/source** of your app/setup, e.g. _region_, _cluster_, _application_, _host_, _pod_, _environment_, etc. [^1]

### Storage and retention

Loki needs a place to store **chunks** and **indexes**.

- "Single Store" Loki, also known as _boltdb-shipper_, uses one store for both chunks **and** indexes.
- You can configure separate stores for chunks and indexes if you prefer.

## Cookbook

### Healthchecks etc

#### Simple healthcheck ('ready' endpoint)

Hit the `/ready` endpoint:

```
kubectl -n production port-forward svc/loki 3100

curl http://localhost:3100/ready
```

### Using logcli

#### Find all labels

```
export LOKI_ADDR=http://yourlokiserver:3100  # uses localhost:3100 by default

$ logcli labels
[tdonohue@dougal loki]$ logcli labels
2022/10/26 09:22:41 http://localhost:3100/loki/api/v1/labels?end=1666772561279838257&start=1666768961279838257
app
app_kubernetes_io_name
app_kubernetes_io_version
application
cluster
...
```

#### Get all log streams (series)

Get all log streams from the past hour (1hr lookback window is the default):

```
$ logcli series {}
2022/10/26 10:04:41 http://localhost:3100/loki/api/v1/series?end=1666775081260042673&match=%7B%7D&start=1666771481260042673
{application="web_app", host="myhost123"}
{app="oracle_exporter", cluster="my-cluster-1"}
{container="myapp_frontend", namespace="myapp-dev", pod="my-pod-123abc"}
...
```

### The API

#### Store a single entry with curl

```
curl -v http://loki:8100/loki/api/v1/push
```

```
{
  "streams": [
    {
      "stream": {
        "job": "test_load"
      },
      "values": [
          [ "1665141665", "my lovely log line" ],
          [ "1665141670", "peanut butter" ]
      ]
    }
  ]
}
```

### LogQL language

#### Fetch some logs with certain labels that match a string

```
{region="eu-west-1", job="loki-prod/querier"} |= "012345abcde"
```

### Extract labels from log lines and use as a filter expression

```
{job="systemd-journal"} | logfmt | 
```

## Troubleshooting

[^1]: <https://grafana.com/go/webinar/getting-started-with-logging-and-grafana-loki/>
[^2]: <https://grafana.com/docs/loki/latest/operations/storage/retention/>
[^3]: <https://grafana.com/docs/loki/latest/operations/multi-tenancy/>

