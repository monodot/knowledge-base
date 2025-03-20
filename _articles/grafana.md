---
layout: page
title: Grafana
---

## Terminology

- If a particular data set has "child" sets with different data models, they are called **frames**. A **data frame** is a collection of **fields**.

## Correlations

Some example correlations:

| Target Type | Target DS | Target Query | Source DS | Source Results Field | Source Transformation Type | Source Transformation Field | Source Transformation Expression | Source Transformation Map Value | What it does |
|------------|-----------|--------------|-----------|----------------------|----------------------------|-----------------------------|---------------------------------|--------------------------------|-----|
| Query | Prometheus data source | `node_memory_MemAvailable_bytes{cluster="$cluster"}` | Loki data source | `Line` | regular expression | `labels` | `"cluster":"([^"]+)"` | `cluster` | Extract the "cluster" label and use it in a Prom query |
| Query | Loki data source | `{cluster="vinson"} |= '${url}'` | Loki data source | `Line` | Regular expression | `Line` | `"GET (.*?) HTTP/1\.1"` | `url` | Parse an Apache log line for a URL and use it in another Loki query |

## Troubleshooting

### Custom plugin seems to disappear from Grafana when developing locally

- A plugin will not appear in the plugins list if it has an invalid manifest. You might see this mentioned in the logs (grep the Grafana logs for the name of your plugin).
  - Delete the plugin's `MANIFEST.txt`, for the plugin to be loaded by Grafana. Then restart Grafana to pick up the changes.
- A plugin may seem in a wonky state (installed, but not enabled) if its plugin.json has a problem.
  - If you've made changes to plugin.json recently, roll back your changes to a known good state.
  - Pay special attention to any changes to your `.includes` object.

