---
layout: page
title: Ansible
---

## Installation

Installation on Fedora may require separately installing Python2 (because Python 3 is the default):

    $ sudo dnf install ansible python2 libselinux-python

## Terminology

**Inventory** is the file that holds hosts information. The default is `/etc/ansible/hosts` or you can provide your own using the `-i` option (usually `-i hosts`):

    [webservers]
    erebus.mndt.co.uk

**Module** are reusable, standalone scripts that can be run using `ansible` or from an `ansible-playbook` command

## Group vars

- Use `group_vars/mygroup` to define a variables file which will be used by playbooks in the group named `mygroup`.
- If a host is defined **in multiple groups**, it will receive the variables from each `group_vars/groupname` file.

## Best practices

Looping:

- [With the release of Ansible 2.5, the recommended way to perform loops is the use the new loop keyword instead of with_X style loops.](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html#migrating-from-with-x-to-loop)

## Cookbook

### Running arbitrary commands

Run DNF update cache on a host as `root` on nodes in the hosts file:

    ansible all -m dnf -a 'update_cache=true' -i ./hosts -u root --become
