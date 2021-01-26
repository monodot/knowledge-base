---
layout: page
title: Prometheus
---

## Getting started

### Concepts, ports

- Prometheus runs on port 9090 by default.

### Deploying on OpenShift 3.x

Deploying a wee Prometheus on OpenShift:

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

## Service discovery

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
