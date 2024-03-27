---
layout: page
title: Grafana
---

## Terminology

- If a particular data set has "child" sets with different data models, they are called **frames**. A **data frame** is a collection of **fields**.

## Troubleshooting

### Custom plugin seems to disappear from Grafana when developing locally

- A plugin will not appear in the plugins list if it has an invalid manifest. You might see this mentioned in the logs (grep the Grafana logs for the name of your plugin).
  - Delete the plugin's `MANIFEST.txt`, for the plugin to be loaded by Grafana. Then restart Grafana to pick up the changes.
- A plugin may seem in a wonky state (installed, but not enabled) if its plugin.json has a problem.
  - If you've made changes to plugin.json recently, roll back your changes to a known good state.
  - Pay special attention to any changes to your `.includes` object.

