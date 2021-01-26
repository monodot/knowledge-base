---
layout: page
title: Vim
---

My all-time favourite commands for _vim_. Check out these classic hits.

## Formatting

Format/indent/pretty-print an XML document:

```
:%!xmllint --format %
```

Change the language/filetype/syntax of a document, for highlighting:

```
:set syntax=groovy
```

Insert spaces instead of tabs (`expandtab`) when pressing the Tab key - how to switch on and off:

```
:set expandtab
:set noexpandtab
```

Change the indent level to 4 spaces:

```
:set shiftwidth=4
```

To insert 4 spaces when pressing the Tab key:

```
:set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
```

## Line manipulation

Append "some text" at the front of every line from here to the end of a file:

```
qi
i "some text \n"
ESC j
@i
q
```

## Searching

Search multiple words:

```
/\vword1|word2|word3
```

Search and highlight multiple phrases (this uses the built-in highlight groups "Search" and "Todo"; to see more groups, type `:highlight`):

```
:match Search /Server is now live/
:2match Todo /backup announced/
:3match Title /another string/
```

## Personalisation

How I set up my Vim ready to use:

1. Install [Vundle] for managing Vim plugins

To install/manage plugins with _Vundle_:

1. Add any plugins required into `/.vimrc`
2. From Vim, type `:PluginInstall`.

To configure syntax highlighting for a file type/extension, add the following to your `~/.vimrc` file:

```
au BufRead,BufNewFile *.adoc set filetype=asciidoc
```

### Using Vim as a Java IDE

Install [SpaceVim].

## SpaceVim

- Install using the instructions at [spacevim.org][spacevim].
- If you installed `vim` using Homebrew, then the SpaceVim install script will install itself into your Homebrew install of Vim, so use that by setting an alias, e.g. `alias vim="/usr/local/Cellar/vim/8.0.0604/bin/vim"`
- If colours don't work on Mac, you need to disable "true colours" (??) - add this line to `~/.SpaceVim.d/init.vim`: `let g:spacevim_enable_guicolors = 0`

Keys:

- Toggle file explorer (VimFiler) - F3

[spacevim]: http://spacevim.org/
[vundle]: https://github.com/VundleVim/Vundle.vim
