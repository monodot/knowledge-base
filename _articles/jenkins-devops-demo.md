---
layout: page
title: DevOps on OpenShift with Jenkins
category: demo
---

This is a basic demo of DevOps on OpenShift, using Jenkins.

Deploy Jenkins from the [Red Hat Communities of Practice Helm Charts][cop]:

    helm repo add redhat-cop https://redhat-cop.github.io/helm-charts

    helm install myjenkins redhat-cop/myjenkins


[cop]: https://github.com/redhat-cop/helm-charts

