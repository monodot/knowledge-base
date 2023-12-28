---
layout: page
title: "Loki: LogQL Metric queries"
lede: "Examples of LogQL queries for generating metrics from logs in Loki."
---


### Using 'topk'

To get the top 10 alerts by count over the last week - use an **Instant query** with the following LogQL:

```logql
topk(10, sum by(labels_alertname, ruleUID) (count_over_time({from="state-history"} | json | current = `Alerting` [1w])))
```
