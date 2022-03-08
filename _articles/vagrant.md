---
layout: page
title: Vagrant
---

## Basics

List all boxes:

    vagrant box list

## Cookbook

Copy a file from host to guest (type `vagrant` when prompted for a password):

    scp -P 2222 /path/to/yourfile.zip vagrant@127.0.0.1:.


