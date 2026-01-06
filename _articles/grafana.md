---
layout: page
title: Grafana
---

## Terminology

- If a particular data set has "child" sets with different data models, they are called **frames**. A **data frame** is a collection of **fields**.

## Alerting & IRM

- An **alert instance** can be Normal, Pending, Alerting, or Recovering
- Define **contact points** to other systems: e.g. Grafana IRM (for complex routing, escalation, etc), Slack, simple email.
- Define a **notification policy** which determines when to route alerts to each contact point.

### IRM

IRM specifically has its own concepts:

- An **alert group** is a collection of related alert instances, bundled together to reduce notification noise. It has four possible states:
  - Firing
  - Acknowledged
  - Resolved
  - Silenced

## Correlations

### Example: Extract cluster label for Prometheus query
- **Target**:
  - Type: Query
  - Data Source: Prometheus
  - Query: `node_memory_MemAvailable_bytes{cluster="$cluster"}`
- **Source**:
  - Data Source: Loki
  - Results Field: `Line`
  - Transformation:
    - Type: regular expression
    - Field: `labels`
    - Expression: `"cluster":"([^"]+)"`
    - Map value: `cluster`
- **What it does**: Extract the "cluster" label and use it in a Prometheus query

### Example: Parse URL from Apache log for Loki query
- **Target**:
  - Type: Query
  - Data Source: Loki
  - Query: `{cluster="vinson"} |= '${url}'`
- **Source**:
  - Data Source: Loki
  - Results Field: `Line`
  - Transformation:
    - Type: Regular expression
    - Field: `Line`
    - Expression: `"GET (.*?) HTTP/1\.1"`
    - Map value: `url`
- **What it does**: Parse an Apache log line for a URL and use it in another Loki query

## Troubleshooting

### Custom plugin seems to disappear from Grafana when developing locally

- A plugin will not appear in the plugins list if it has an invalid manifest. You might see this mentioned in the logs (grep the Grafana logs for the name of your plugin).
  - Delete the plugin's `MANIFEST.txt`, for the plugin to be loaded by Grafana. Then restart Grafana to pick up the changes.
- A plugin may seem in a wonky state (installed, but not enabled) if its plugin.json has a problem.
  - If you've made changes to plugin.json recently, roll back your changes to a known good state.
  - Pay special attention to any changes to your `.includes` object.

