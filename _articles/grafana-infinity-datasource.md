---
layout: page
title: Grafana Infinity Datasource
---

A data source for getting REST APIs into a Grafana dashboard.

## Parsers

The parsers are:

- **Default:**
- **Backend:**
- **UQL:**
- **GROQ:**

## Computed columns, Filter and Group By examples

Filter examples:

- `state == 'Alerting'`

Computed column examples:

- Building strings: `'gcloud container clusters get-credentials ' + Name + ' --location ' + Location + ' --project ${google_project}'`
- Creating a column to alert on: `status == 'alerting' ? 1 : 0` as _alerting_


## Cookbook

### Use UQL to iterate over a key in the JSON

An example UQL expression which iterates over the key `data` in some JSON:

```
parse-json
| scope "data"
```

### Use UQL to convert an array into a map

Converts, e.g. `{ "clusters": [ "a", "b", "c", "d" ] }` into `[ { name: "a", cmd: "aws eks" }]`

```
parse-json 
| project "foo"=array_from_entries('name', "clusters") 
| project "name"="name", "cmd"=strcat(str("aws eks update-kubeconfig --name "),"name",str(" --region ${region}"))
```

### Creating dynamic results with 'computed columns'

**Computed columns** (with parser: Backend) can contain an expression which includes string concatenation.

**Example:** take the `Location` field from the API response, and the dashboard variable `google_project`, and use them to create an example command:

```
'gcloud container clusters get-credentials ' + Name + ' --location ' + Location + ' --project ${google_project}'
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

### How to configure an alert on an Infinity data source

If you want to create an alert on data from an API, then you'll need to get (or calculate) a numeric column that indicates whether the given instance (row) is in an alert state, and strip away any superfluous columns.

For example:

1. Set the Parser to **Backend**

2. Set the URL, e.g. `https://example.com/api/v1/devices/123456/statuses` 

3. Under Columns, manually extract only the columns you need, e.g.:

    - `deviceIp` AS `deviceIp`, format as _String_
    - `network` as `network`, format as _String_
    - `status` as `status`, format as _String_ (or extract your "alert" column here)

4. If the API doesn't have a numeric column that indicates a thing/row is in an alert state, create one as a _Computed column_:

    - Expression: `status == 'alerting' ? 1 : 0`
    - As: `alerting`

Grafana Alerting will alert on an _instance_ when this `alerting` column is non-zero. It will also use the `deviceIp`, `network` and `status` fields as labels.

Issues/troubleshooting:

- _input data must be a wide series but got type not (input refid)_ - follow the instructions above to convert your Infinity API response into a valid Table for Grafana Alerting.

See also: https://grafana.com/docs/grafana/latest/alerting/fundamentals/alert-rules/queries-conditions/#alert-on-numeric-data 
