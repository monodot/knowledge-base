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
