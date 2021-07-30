---
layout: page
title: TeX and LaTeX
---

> TeX is both a **program** (which does the typesetting, _tex-core_) and **format** (a set of macros that the engine uses, _plain-tex_)

> LaTeX is a generalised set of **macros** ... to set up things like sections, title pages, bibliographies and so on

-- <https://tex.stackexchange.com/questions/49/what-is-the-difference-between-tex-and-latex>

## Concepts

- **TikZ** - package in LaTeX for drawing nice diagrams.

## Document classes (LaTex)

Here are some of the more common LaTeX document classes:

| Class name | Info               |
| ---------- | ------------------ |
| `beamer`   | For producing presentations and slides. |
| `report`   | Doesn't support subtitle. |
| `scrreprt` | KOMA-Script version of `report`. Supports subtitle. |

## Getting started on Fedora

### Document editor: LyX

LyX is a Linux GUI application which can you can use to write documents and then render to LaTeX or PDF:

```
dnf install lyx
```

### Installing a style file

To install a TeX `.sty` file, first see if it's available in a package. For example, if I want the `cancel.sty` file, I can see that it's in the package `texlive-cancel`:

```
$ dnf provides "*/cancel.sty"
texlive-cancel-8:svn32508.2.2-25.fc30.noarch : Place lines through maths formulae
```

- Lyx layouts are located in `/usr/share/lyx/layouts`
- When changing document settings/styles through the dialog boxes, "Save as Document Defaults" will save your preferences to the file `~/.lyx/templates/defaults.lyx`

## Getting started on macOS

### Install MacTeX with Homebrew

```
brew cask install mactex
```

### Install packages

To use _packages_ (from [CTAN][ctan]), use the **TeX Live Utility** in the Applications/TeX folder.

- First TeX Live Utility may need to update core packages
- Then to update a package, find it in the list, right-click and choose the appropriate option.

### Syntax highlighting with _minted_

Using the `minted` package:

- `minted` uses Pygments for syntax highlighting. Add `--shell-escape` as a command line argument to `pdflatex` in TeXShop preferences
- Ensure Pygments is installed: `pip install pygments` (Python must be installed first)

## Troubleshooting

_"LaTeX Error: File `cancel.sty' not found."_

- On Fedora, find which package provides it - e.g. using `dnf provides "*/cancel.sty"`, then install the appropriate  package - `texlive-cancel`

## Related links

- [pandoc-latex-template](https://github.com/Wandmalfarbe/pandoc-latex-template) - A pandoc LaTeX template to convert markdown files to PDF or LaTeX. 

[ctan]: https://www.ctan.org
