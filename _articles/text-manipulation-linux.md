---
layout: page
title: Text manipulation in Linux
---

## Common commands

- `awk`
- `tac` - concatenate and print files in reverse

## Cookbook

### Deduplicating a file

Remove duplicate lines in a file, where **values in one column are the same**, whilst preserving order. For example, removing duplicate properties in a key/value property file (e.g. a Java `.properties` file). Either keep the **first** occurrence of the duplicate column line:

    awk -F'=' '!seen[$1]++' foo.properties

...or keep the **last occurrence** of the duplicate column line:

    tac foo.properties | awk -F'=' '!seen[$1]++' | tac
