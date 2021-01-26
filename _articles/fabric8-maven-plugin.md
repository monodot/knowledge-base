---
layout: page
title: Fabric8 Maven Plugin
---

## Cookbook

### Specifying a base image

FMP will try to make an educated guess about which base image to use, e.g.:

> Using ImageStreamTag 'fuse7-java-openshift:1.4' from namespace 'openshift' as builder image

To override this (with an ImageStreamTag):

    mvn fabric8:deploy fabric8.generator.fromMode=istag -Dfabric8.generator.from=mynamespace/my-image:mytag -Pfabric8
