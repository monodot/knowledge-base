---
layout: page
title: Grafana Infinity Datasource
---

A data source for getting REST APIs into a Grafana dashboard.

## Settings and examples

### Computed columns, Filter, Group By

**Computed columns** (with parser: Backend) can have an expression which includes strings concatenation.

Example: take the `Location` field from the API response, and the variable `google_project`, and use them to create an example command:

```
'gcloud container clusters get-credentials ' + Name + ' --location ' + Location + ' --project ${google_project}'
```

### UQL

An example UQL expression which iterates over the key `data` in some JSON:

```
parse-json
| scope "data"
| 
```

### How to validate parts of a YAML document

To fetch a YAML document and then validate parts of it (e.g. evaluate some custom rules):

- Type: UQL
- Source: URL
- Format: Table
- URL: http://example.com/example.yaml

Then in the UQL box, parse the YAML into JSON, and use the _jsonata_ function to evaluate expressions of your choosing:

```
parse-yaml
| jsonata "{ \"memcached_host_configured\": $.chunk_store_config.chunk_cache_config.memcached_client.host != '', \"ruler_evaluation_interval\": $.ruler.evaluation_interval }"
| project kv()
```

When displayed in a Table panel in Grafana, this should result in something like:

| key | value |
| --- | ----- |
| is_memcached_host_configured | true |
| ruler_evaluation_interval | 1m0s |
