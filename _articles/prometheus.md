---
layout: page
title: Prometheus
---

A time series database, for storing and serving metrics.

### Basics

- Prometheus runs on port 9090 by default.

## Getting started

### Deploying on OpenShift 3.x

Deploying a wee Prometheus on OpenShift 3.11:

```
oc process -f https://raw.githubusercontent.com/openshift/origin/release-3.11/examples/prometheus/prometheus-standalone.yaml

oc create -f - <<HELLO
apiVersion: v1
kind: Secret
metadata:
  name: prom
stringData:
  prometheus.yml: |
    global:
      scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
      evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
      # scrape_timeout is set to the global default (10s).

    # Alertmanager configuration
    alerting:
      alertmanagers:
      - static_configs:
        - targets:
          # - alertmanager:9093

    # A scrape configuration containing exactly one endpoint to scrape:
    # Here it's Prometheus itself.
    scrape_configs:
      # The job name is added as a label `job=` to any timeseries scraped from this config.
      - job_name: 'prometheus'

        # metrics_path defaults to '/metrics'
        # scheme defaults to 'http'.

        static_configs:
        - targets: ['localhost:9090']

      # Scrape configuration for our hello world app
      - job_name: 'myapp'
        static_configs:
        - targets: ['myapp:8080']
HELLO

oc create -f - <<HELLO
apiVersion: v1
kind: Secret
metadata:
  name: prom-alerts
stringData:
  alertmanager.yml: |
    global:
    # The root route on which each incoming alert enters.
    route:
      # default route if none match
      receiver: alert-buffer-wh
    receivers:
    - name: alert-buffer-wh
      webhook_configs:
      - url: http://localhost:9099/topics/alerts
HELLO
```

## Scraping metrics

### Listing metrics from an existing app

If you're running an application which already exposes metrics for Prometheus, and you want to see which metrics are exposed.

For example, for [Loki](loki.html) which runs on port 3100:

```shell
# 
kubectl port-forward loki-pod-name 3101:3100

# Then fetch the metrics endpoint - usually at /metrics
curl localhost:3101/metrics
```

## Cookbook

### Rates

- Use **irate** for volatile, fast-moving counters
- Use **rate** for alerts and slow-moving counters

From a counter of HTTP requests, get the per-second rate of HTTP requests, measured over the last 5 minutes:

```
rate(http_requests_total{job="api-server"}[5m])
```

### Alert queries

#### Get the error rate

```
100 * sum by(job) (rate(http_server_duration_count{http_status_code=~"5.."}[$__rate_interval])) / sum by(job) (rate(http_server_duration_count[$__rate_interval]))
```

#### Predict a node's free disk space in X hours

```
predict_linear(node_filesystem_avail_bytes{job="node"}[1h], 8 * 3600) < 0
```

- Get 1 hour's worth of `node_filesystem_avail_bytes` history
- Use `predict_linear` to predict 8 hours ahead (8 x 3600)
- Test whether the value will be less than 0 - i.e. no free disk space

[Source][1]

## Targets

### Kubernetes

Prometheus uses **Kubernetes Service Discovery (SD)** to be able to scrape targets using the Kubernetes REST API.

1. Set up a job in Prometheus which uses Kubernetes Service Discovery. e.g. this configuration fragment from a sample _prometheus.yml_:

  ```
  - job_name: 'kubernetes-service-endpoints'

  kubernetes_sd_configs:
  - role: endpoints
  ```

2. Add the following `annotations` (not Labels!) to the Service in Kubernetes that you want to be scraped:

```
prometheus.io/scrape: "true"
prometheus.io/path: "/metrics"
prometheus.io/port: "8672"
```

[1]: https://www.robustperception.io/reduce-noise-from-disk-space-alerts/
