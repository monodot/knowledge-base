---
layout: page
title: Grafana SLO
---

## Best practices

- **Don't** use histogram_quantile to calculate the P95 latency and then compare it to a threshold. Calculating percentiles from histograms can be inaccurate and you can’t aggregate the P95 values together for higher level reporting. 
  - **Do** use prometheus histograms with `le` buckets to count how many requests were returned with latency "less than or equal to" your `le="1.0"` threshold. [source](https://grafana.com/docs/grafana-cloud/alerting-and-irm/slo/best-practices)

## Example SLO queries

### Requests to a service that received a response in less than 300ms

Advanced query:

    sum(rate(
    http_request_duration_seconds_bucket{le="0.3"}[$__rate_interval]
    )) by (job)
    /
    sum(rate(
    http_request_duration_seconds_count[$__rate_interval]
    )) by (job)

Source: https://grafana.com/docs/grafana-cloud/alerting-and-irm/slo/create/

### Requests to a service that have a high error rate

"Error" query:

    sum(rate(http_request_duration_seconds_count{job="myservice",code=~"(5..|429)"}[$__rate_interval]))

"Total" query:

    sum(rate(http_request_duration_seconds_count{job="myservice"}[$__rate_interval]))

Source: https://sloth.dev/examples/default/getting-started/

### Successful requests should take less than 1 second

Ratio query - "success" query:

    requests_duration_seconds_bucket{code!~"5..", le="1.0"}

"Total" query:

    requests_duration_seconds_count{code!~"5.."}

### Requests should take less than 1 second

"Advanced" query - use `_bucket` and then `_count`:

    (sum by (cluster, namespace) (rate(http_request_duration_seconds_bucket{status_code!~"5..",route="/cart", job="mynamespace/myapp", le=~"1|1\\.0"}[$__rate_interval]))) 
    / 
    (sum by (cluster, namespace) (rate(http_request_duration_seconds_count{status_code!~"5..",route="/cart", job="mynamespace/myapp"}[$__rate_interval])))

### Work items should be processed in a given time or less

    completed_duration_seconds_bucket{le="120"} / completed_duration_seconds_count

Source: https://grafana.com/docs/grafana-cloud/alerting-and-irm/slo/best-practices

