---
layout: page
title: Grafana Enterprise Logs
---

## Targets

Here are the targets available in the enterprise-logs image:

```bash
$ podman run -it --entrypoint sh docker.io/grafana/enterprise-logs:v1.5.2


```

## Deployment with Tanka

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

### Get tenants

```
export GEL_ADMIN_TOKEN=token_of_your_admin_user

curl -u :$GEL_ADMIN_TOKEN http://localhost:8100/admin/api/v3/tenants
```

### Push 2 log entries into GEL deployed on Kubernetes (with authentication)

```
kubectl -n gel port-forward svc/ge-logs 8100

export GEL_PUSH_TOKEN=your_auth_token_goes_here
export GEL_TEST_TIME=$(date +%s%N)
export GEL_TENANT_ID=your_gel_tenantid

curl -v -u ${GEL_TENANT_ID}:$GEL_PUSH_TOKEN \
  -H "Content-Type: application/json" \
  -H "X-Scope-OrdID: ${GEL_TENANT_ID}" \
  -X POST \
  http://localhost:8100/loki/api/v1/push --data @- <<EOF
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



