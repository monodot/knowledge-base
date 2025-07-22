---
layout: page
title: Tempo
lede: "Tempo is a database for storing distributed traces."
---

## Common issues

### Spans arriving too late

- Happens when a span arrives with an end time that is outside the current metrics generation period / 'tick'
- The span still exists, and can be searched for in Tempo, but it never gets included in a metric
- Can be caused by:
  - Batching / buffering - e.g. if traces are buffered several times in a collection pipeline
  - Network delays / retries
- Increasing the slack time allows these "late" spans to have a metric generated for them
- **BUT** it means that the granularity of the metrics is reduced, i.e. instead of periods of 30 seconds, now your granularity is 1m, 2m, or whatever is configured.

## Cookbook

### Fetch a trace from Grafana Cloud Traces

Example, change the URL depending on the region/cluster:

```sh
export TEMPO_ID=123456
export CAP_TOKEN=glc_...

curl -u "${TEMPO_ID}:${CAP_TOKEN}" "https://tempo-prod-26-prod-us-east-2.grafana.net/tempo/api/traces/a4a4176f1c84829b1b3fe98b2236fe"
```

