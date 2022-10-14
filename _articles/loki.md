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
- You can combine Loki with Prometheus _Alertmanager_ to send send notifications when things happen.

### Use cases

Examples of things that you might put into Loki:

- Nginx logs
- IIS logs
- Cloud-native app logs
- Linux server logs (systemd journal)
- Kubernetes logs (via service discovery)
- Docker container logs

### Clients

How to get data into Loki:

- Promtail
- Grafana Agent
- Log4J
- Logstash

## Getting started

### Running Loki 2.6.1 and Promtail with podman-compose on Fedora

```
git clone https://github.com/monodot/grafana-demos
cd grafana-demos/loki-basic
podman-compose up -d
```

## Using Loki

### Labels and indexing

- Prefer labels that describe the **topology/source** of your app/setup, e.g. _region_, _cluster_, _application_, _host_, _pod_, _environment_, etc. [^1]

### Storage and retention

Loki needs to store **chunks** and **indexes**.

- "Single Store" Loki, aka _boltdb-shipper_, uses one store for chunks and indexes.

#### Retention

- Loki doesn't delete old chunk stores, unless you're using the `filesystem` chunk store type.
- To configure deletion, set up a retention duration.

The BoltDB Shipper includes a component called the Compactor:

- If you're using the **boltdb-shipper** store, you can configure the _Compactor_ to perform retention.
- If you're using the _Compactor_, you don't need to also configure the _Table Manager_.

Chunk storage:


Index storage:





### Scalability

<!-- - Prefer object stores (e.g. S3) as a backend. -->

## Cookbook

### The API

#### Store a single entry with curl

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


[^1]: <https://grafana.com/go/webinar/getting-started-with-logging-and-grafana-loki/>
