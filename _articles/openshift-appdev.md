---
title: OpenShift for App Dev
---

Stuff and scenarios for application development on OpenShift.

## Basic Jenkins demo

Get access to an OpenShift cluster first.

```
oc new-project td-cicd

oc new-app https://github.com/monodot/container-up
oc expose svc container-up

oc new-project td-cicd-prod

oc new-app container-up

```