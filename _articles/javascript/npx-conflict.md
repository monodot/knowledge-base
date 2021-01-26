---
layout: page
title: npx conflicts with local, existing command
---

Sometimes `npx` can exhibit weird behaviour when there is already a command installed with the same name as the package you're trying to install.

From the docs for `npx`:

> By default, npx will check whether <command> exists in $PATH, or in the local project binaries, and execute that.

For example, on Fedora Linux, there is an ancient utility `sb`, which conflicts with the NPM package called `sb` (Storybook for JavaScript):

```
$ npx sb init  
sb: cannot open init: No such file or directory

Can't open any requested files.

$ sb init
sb: cannot open init
```

So `npx` notices `sb` exists on the PATH, and tries to run the `sb` command. But actually we want to run the `sb` **NPM package**.

Be explicit about which NPM package you want to run the command from, by giving the `--package name`, e.g.:

```
$ npx --package sb sb init
```

