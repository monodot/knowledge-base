---
layout: page
title: Loki
---

Loki is a log aggregation system written in Go, inspired by Prometheus.

{% include toc.html %}

## Fundamentals

- Loki is a time-series database for strings. [^1]
- Loki exposes an HTTP API for pushing, querying and tailing log data.
- Loki stores logs as strings exactly how they were created, and indexes them using _labels_.
- Loki is usually combined with _agents_ such as Promtail, which are responsible for turning logs into streams and pushing them to the Loki HTTP API.

Things you might put into Loki:

- Nginx logs
- IIS logs
- Cloud-native app logs
- Linux server logs (systemd journal)
- Kubernetes logs (via service discovery)
- Docker container logs

## Getting started

### Running Loki 2.6.1 with podman-compose on Fedora

```
git clone https://github.com/monodot/grafana-demos
cd grafana-demos/loki-basic
podman-compose up -d
```

## Operations

### Labels and indexing

- Prefer labels that describe the **topology** of your app/setup, e.g. _region_, _host_, _pod_, _environment_, etc. [^1]

### Scalability

- Prefer object stores (e.g. S3) as a backend.

## Cookbook

### LogQL language

#### Fetch some logs

```
{region="eu-west-1", job="loki-prod/querier"} |= "012345abcde"
```



[^1]: <https://grafana.com/go/webinar/getting-started-with-logging-and-grafana-loki/>
