---
layout: page
title: VPN (and VPN hacks)
---

## Concepts

## Split tunnelling with `vpn-slice` and `openconnect`

**tun0** is a VPN interface.

Split tunnelling is where you only want **some traffic** to be routed through a VPN connection, rather than **all traffic**. This is done using fancy things like IP routes and modifying the `hosts` file.

`vpn-slice` is a python utility which makes it easier to configure `openconnect` or `vpnc` to pass only selected traffic through the VPN.

    sudo dnf install -y python3-devel
    sudo pip3 install --prefix /usr/local https://github.com/dlenski/vpn-slice/archive/master.zip

Heavy credits [go to Stefan's Gist](https://gist.github.com/stefancocora/686bbce938f27ef72649a181e7bd0158#establish-vpn-connection) for this one.

## Cookbook

Using `sshuttle` to make a VPN connection when stuck on a guest network that seems to block VPN connections:

    sshuttle -r <your username>@ovpn.example.com:330 0.0.0.0/0 --dns
