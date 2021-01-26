---
layout: page
title: Flatpak
---

Flatpak is another way of installing apps onto Linux or something.

## Installing something

The default installation will install for all users **and probably put stuff onto the root partition**. If this is not what you want, then install for your current user, using:

```
flatpak --user install flathub io.atom.Atom
```

## Keeping tabs on size

A bunch of files are created in `/var/lib/flatpak` (in the default installation):

> Flatpak uses OSTree to distribute and manage applications and runtimes. The repo/ in the above tree is the local OSTree repository.

To uninstall all _unused_ packages:

```
flatpak uninstall --unused
```
