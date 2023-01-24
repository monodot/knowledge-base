---
layout: page
title: Grafana Enterprise Logs
---

Grafana Enterprise Logs is the commercial distribution of [Loki][loki].

## Quickstart

### Run GEL 1.5.2 with Podman - for testing only! (no persistence)

```shell
cat > config.yaml <<EOF
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
  - from: 2020-05-15
    store: boltdb
    object_store: filesystem
    schema: v11
    index:
      prefix: index_
      period: 168h

storage_config:
  boltdb:
    directory: /tmp/loki/index

  filesystem:
    directory: /tmp/loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
EOF

podman run -it -p 3100:3100 -v $(pwd)/config.yaml:/etc/loki/config.yaml grafana/enterprise-logs:v1.5.2 -config.file=/etc/loki/config.yaml
```

## Targets

Here are the targets available in the enterprise-logs image:

```bash
$ podman run -it --entrypoint sh docker.io/grafana/enterprise-logs:v1.5.2
```

## Deployment


### Deploy GEL 1.5.2 with Tanka

An example Tanka override override file `environments/enterprise-logs/main.jsonnet`:

```
local gel = import 'github.com/grafana/loki/production/ksonnet/enterprise-logs/main.libsonnet';

gel {
  _config+:: {
    commonArgs+:: {
      'admin.client.backend-type': 's3',
      'admin.client.s3.access-key-id': 'minio',
      'admin.client.s3.bucket-name': 'grafana-logs-admin',
      'admin.client.s3.endpoint': 'minio:9000',
      'admin.client.s3.insecure': true,
      'admin.client.s3.secret-access-key': 'minio123',
      'cluster-name': 'mygelcluster',
    },

    namespace: 'enterprise-logs',

    boltdb_shipper_shared_store: 's3',
    storage_backend: 's3',
    s3_access_key: 'minio',
    s3_address: 'minio:9000',
    s3_bucket_name: 'grafana-logs-data',
    s3_secret_access_key: 'minio123',

    ingester_pvc_class: 'standard'

  },

  _images+:: {
    loki: 'grafana/enterprise-logs:v1.5.2'
  },

  // Deploy tokengen Job available on a first run.
  tokengen_job+::: {},
}
```

## Cookbook

### Tenant management

#### Get tenants

```
export GEL_ADMIN_TOKEN=token_of_your_admin_user

curl -u :$GEL_ADMIN_TOKEN http://localhost:8100/admin/api/v3/tenants
```

### Sending logs

#### Push 2 log entries into a GEL cluster deployed on Kubernetes (with authentication)

```shell
kubectl -n gel port-forward svc/ge-logs 8100

export GEL_ENDPOINT=localhost:8100
export GEL_PUSH_TOKEN=your_auth_token_goes_here
export GEL_TEST_TIME=$(date +%s%N)

# Your tenant ID is just the name of the tenant in GEL
export GEL_TENANT_ID=healingcrystals

curl -v -u ${GEL_TENANT_ID}:${GEL_PUSH_TOKEN} \
  -H "Content-Type: application/json" \
  -H "X-Scope-OrdID: ${GEL_TENANT_ID}" \
  -X POST \
  http://${GEL_ENDPOINT}/loki/api/v1/push --data @- <<EOF
{
  "streams": [
    {
      "stream": {
        "job": "test_job",
        "meal": "breakfast"
      },
      "values": [
          [ "${GEL_TEST_TIME}", "my log line is here" ],
          [ "${GEL_TEST_TIME}", "peanut butter on toast" ]
      ]
    }
  ]
}
EOF
```

[loki]: {% link _articles/loki.md %}
