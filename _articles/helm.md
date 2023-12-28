---
layout: page
title: Helm
---

## Installing on Fedora

No packages yet :( No manpages either :(

```
curl -OL https://get.helm.sh/helm-v3.4.2-linux-amd64.tar.gz
tar -zxvf helm-v3.4.2-linux-amd64.tar.gz linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm
```

## Concepts

Tracking the state of releases in the cluster:

- Helm 3 uses Secrets to track releases.
- [A release has one or more release version secrets associated with it](https://helm.sh/blog/helm-3-preview-pt4/)
- Each release version secret describes one version of the release.
- Upgrades create a new release version secret.

## Cookbook

### Get the values.yaml for any Helm chart

To dump the values.yaml for any Helm chart:

```
helm show values stable/wordpress > values.yaml
```


## Troubleshooting

403 Forbidden error when trying to access the "stable" repo (kubernetes-charts.storage.googleapis.com):

- _stable_ and _incubator_ repositories have moved:
  - _stable_ is now: <https://charts.helm.sh/stable>
  - _incubator_ is now: <https://charts.helm.sh/incubator>
- To update: `helm repo add stable https://charts.helm.sh/stable --force-update`
- Upgrade to Helm v3.4.0 or later to get warnings about the new locations
- [See the blog about this](https://helm.sh/blog/new-location-stable-incubator-charts/)

