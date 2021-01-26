---
layout: page
title: TeX
---

## Quickstart on Fedora

Writing with LyX:

```
dnf install lyx
```

To install a TeX `.sty` file, first see if it's available in a package. For example, if I want the `cancel.sty` file, I can see that it's in the package `texlive-cancel`:

```
$ dnf provides "*/cancel.sty"
texlive-cancel-8:svn32508.2.2-25.fc30.noarch : Place lines through maths formulae
```

- Lyx layouts are located in `/usr/share/lyx/layouts`
- When changing document settings/styles through the dialog boxes, "Save as Document Defaults" will save your preferences to the file `~/.lyx/templates/defaults.lyx`

## Basic installation on Mac

```
brew cask install mactex
```

Then to use _packages_ (from [CTAN]), use the **TeX Live Utility** in the Applications/TeX folder.

- First TeX Live Utility may need to update core packages
- Then to update a package, find it in the list, right-click and choose the appropriate option.

Using the `minted` package:

- `minted` uses Pygments for syntax highlighting. Add `--shell-escape` as a command line argument to `pdflatex` in TeXShop preferences
- Ensure Pygments is installed: `pip install pygments` (Python must be installed first)

## Troubleshooting

_"LaTeX Error: File `cancel.sty' not found."_

- Install the cancel package - `texlive-cancel`

_"LaTeX Error: File `maa-monthly.sty' not found."_

- Find which package provides it in Fedora - e.g. `dnf provides "*/cancel.sty"`
- Install the cancel

[ctan]: https://www.ctan.org
