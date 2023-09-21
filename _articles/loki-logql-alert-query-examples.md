---
layout: page
title: "Loki: Rule query examples"
lede: "Examples of LogQL queries for alerting in Loki."
---

## Alert queries

### A specific string is seen in the logs

This could be used to raise an alert whenever the app crashes.

```
(rate({app="my-app"} |= "my app has crashed" [1m])) > 1
```

### Rate of logs is too slow

This could imply that the application has stopped logging, or that the application is running slowly. Alerts would be raised if the rate of logs drops below 100 per minute, summed by region and cluster.

```
(sum by (region, cluster) (rate({app="my-app"} [1m])) < 100)
```


