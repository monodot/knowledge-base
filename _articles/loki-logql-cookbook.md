---
layout: page
title: "Loki: LogQL Cookbook"
lede: "Examples of LogQL queries for generating metrics from logs in Loki."
---


## Parsing examples

### Pattern parser

```
{service_name="recommendationservice"} | pattern `<_> Updated inventory for <_> (<product_id>)`
```

### Regexp parser

Parse the WebKit version from NGINX logs, and draw a graph of sum totals:

```
{filename="/var/log/nginx/json_access.log"} | regexp `WebKit/(?P<webkit_version>[0-9]+\.[0-9]+)`

sum by(webkit_version) (count_over_time({filename="/var/log/nginx/json_access.log"} | regexp `WebKit/(?P<webkit_version>[0-9]+\.[0-9]+)` | logfmt | __error__=`` [$__auto]))
```

## Metric queries

### Using 'topk'

Get the top 10 alerts (by count) over the last week by counting the number of log lines - use an **Instant query** with the following LogQL:

```logql
# Instant query
topk(10, sum by(labels_alertname, ruleUID) (count_over_time({from="state-history"} | json | current = `Alerting` [1w])))
```

Use `topk` to get the top 20 users by total bytes queried, by unwrapping the `total_bytes` field from each log line:

```logql
# Instant query
topk(20, sum by (grafana_username) (sum_over_time({org_id="12345"} |= "query event" | logfmt | unwrap bytes(total_bytes)[$__range])))
```

### Join by label, with `unless`

Find all jobs which started, but didn't finish:

```logql
sum by (jobId) (
  count_over_time({service_name="loki-alert-missing-log"} | logfmt | event=`started` [12h])
)
unless
sum by (jobId) (
  count_over_time({service_name="loki-alert-missing-log"} | logfmt | event=`completed-successfully` [12h])
) 
> 0
```

Should return a table of results like this (presented here as CSV) - correctly identifying 7671 as the job that didn't complete:

```
"Time","jobId","Value #combined"
2025-02-20 11:23:30,64061cd8-9a0c-43bd-a451-e1f6e6ac7671,1
```


