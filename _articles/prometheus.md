---
layout: page
title: Prometheus
---

A time series database, for storing and serving metrics.

## Getting started

### Basics

- Prometheus runs on port 9090 by default.

## Metric types

### Histogram

A histogram _"is a graphical representation of the distribution of numerical data. It is a type of bar chart that shows the frequency or number of observations within different numerical ranges, called bins."_ (or _buckets_, in Prometheus-speak).

```
Scores  | Distribution
90-100  | **
80-89   | ****
70-79   | *****
60-69   | ***
50-59   | *
```

A **histogram metric** consists of a few metrics:

- `_count`: the total number of measurements
- `_sum`: the sum of the values of all measurements
- `_bucket`: counters for each bucket, identified by a `le` label (a label that describes the upper bounds of a bucket)

To use a histogram:

- Use the `histogram_quantile` function to calculate quantiles from a histogram.

Examples:

- `http_request_duration_seconds_count`, `http_request_duration_seconds_sum`, `http_request_duration_seconds_bucket`

### Counter

- Counters end in `_total`

### Gauge

- Gauges end in `_bytes` or `_total`
- `le` is a label for the upper bounds of a histogram bucket

### Terminology, terms of art

- A **vector** is a one-dimensional list, of which there are two types:
  - **Instant vector** is a list of zero or more time series, each containing 1 **sample**, with its original timestamp and value.
  - **Range vector** is a list of zero or more time series, each containing many samples for each time series
  - You almost always use a range vector with a function like `rate` or `avg_over_time`
- **Instant query** - produces a table-like view, where you want to show the result of a PromQL query at a single point in time. [2]
- **Scalar** is a single numeric value, like `1.234`, often used as some argument in a query

### Examples

```
# Instant vector selector
process_resident_memory_bytes{job="node"}

# Range vector - many samples for each time series
rate(process_cpu_seconds_total[1m])

# 'range:resolution' syntax - every 1 min for the last 30 min
max_over_time( rate(http_requests_total[5m])[30m:1m] )
```

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

### Viewing an app's metrics endpoint

If you're running an application which already exposes metrics for Prometheus, and you want to see which metrics are exposed.

For example, for [Loki](loki.html) which runs on port 3100:

```shell
# 
kubectl port-forward loki-pod-name 3101:3100

# Then fetch the metrics endpoint - usually at /metrics
curl localhost:3101/metrics
```

## PromQL cheat sheet

- `topk` - 

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

### Joins

```
myapp_instance_request_count{region="eu"} by (cluster, id) * on (cluster, id) group_left(app_version, url) myapp_instance_info{}
```

Another join, this time we're fetching the `slug` label from the right-hand metric, and using `topk` to reduce the number of results on the right-hand side to 1:

```
myapp_instance_request_count{region="eu"} * on(cluster, id) group_left(slug) topk by(cluster, id) (1, myapp_instance_info)
```

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
[2]: https://promlabs.com/blog/2020/06/18/the-anatomy-of-a-promql-query/
