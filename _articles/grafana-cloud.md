---
layout: page
title: Grafana Cloud
---

## Cookbook

### Send some logs and delete them

Put some log entries into Grafana Cloud Logs:

```bash
export LOKI_USERNAME=123456
export LOKI_PASSWORD=yourapikey
export LOG_TIME=$(date +%s%N)
export LOKI_HOST=logs-prod-000.grafana.net

curl -v -u ${LOKI_USERNAME}:${LOKI_PASSWORD} \
  -H "Content-Type: application/json" \
  -X POST \
  https://${LOKI_HOST}/loki/api/v1/push --data @- <<EOF
{
  "streams": [
    {
      "stream": {
        "job": "test_load", 
        "meal": "breakfast"
      },
      "values": [
          [ "${LOG_TIME}", "my log line is here" ],
          [ "${LOG_TIME}", "peanut butter on toast" ]
      ]
    }
  ]
}
EOF
```

Verify that the labels are there:

```bash
curl -u ${LOKI_USERNAME}:${LOKI_PASSWORD} https://${LOKI_HOST}/loki/api/v1/labels

# should return something like:
# {"status":"success","data":["meal","job"]}
```

Now issue a delete request (your token needs to have the 'Admin' role):

```bash
# you can also provide an 'end' date as long as it's not in the future
curl -u ${LOKI_USERNAME}:${LOKI_PASSWORD} -g -X POST "https://${LOKI_HOST}/loki/api/v1/delete?query={meal=\"breakfast\",job=\"test_load\"}&start=2022-11-15T00:00:00Z"
```

The deletion request should now be queued; to view all deletion requests:

```bash
curl -u ${LOKI_USERNAME}:${LOKI_PASSWORD} https://${LOKI_HOST}/loki/api/v1/delete | jq
# [
#   {
#     "request_id": "9fdb87cc",
#     "start_time": 1668470400,
#     "end_time": 1668516324.708,
#     "query": "{meal=\"breakfast\",job=\"test_load\"}",
#     "status": "received",
#     "created_at": 1668516324.708
#   }, ...
```

## Grafana Agent

### Running Grafana Agent locally

When running the Agent locally, it expects a configuration file in `/etc/grafana-agent.yaml`.

To check the status of the monitoring agent:

    systemctl status grafana-agent

To look at the logs from the agent itself:

    journalctl -u grafana-agent

### Running Grafana Agent on Kubernetes

An example deployment: https://github.com/grafana/agent/blob/main/production/kubernetes/agent-bare.yaml

A deployment of Grafana Agent on Kubernetes consists of:

- Grafana Agent: ConfigMap `grafana-agent`, and StatefulSet `grafana-agent` which runs the agent itself
- Kube-state-metrics: ServiceAccount, ClusterRole, ClusterRoleBinding, Service, Deployment.
  - **About _ksm_ for cluster-level metrics:** _ksm_, or [_kube-state-metrics_](https://github.com/kubernetes/kube-state-metrics), is a project from the Prometheus community which watches Kubernetes resources, and emits Prometheus metrics that can be scraped by Grafana Agent.
- Grafana Agent for Logs/Loki: A ConfigMap `grafana-agent-logs`, ServiceAccount, ClusterRole, ClusterRoleBinding and DaemonSet for `grafana-agent-logs`







