---
layout: page
title: GitHub Actions
---

## Running locally with 'act'

Install act:

```shell
gh extension install https://github.com/nektos/gh-act
```

Run all workflows with push event

```shell
gh act push
```

Runs all workflows with the workflow_dispatch event:

```shell
gh act workflow_dispatch -e payload.json
```
