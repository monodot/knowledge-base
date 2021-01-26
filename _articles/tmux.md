---
layout: page
title: Tmux
---

- **Windows** in tmux are basically tabs.
- **Panes** are the individual split terminals you see on one screen.

## Tmux basics

Launch tmux:

    tmux

Resizing panes:

- Resize a pane taller or shorter: `<bind key> <Ctrl+Up,Down>`

Find what the prefix-key is set as:

    tmux list-keys

    # or, within a tmux session, you can do (prefix-key) + ?

Quit a terminal session within Tmux:

    <Ctrl+D>

Create a new horizontal pane:

    Ctrl+B, %

Create a vertical pane:

    Ctrl+B, "

Scroll within a pane:

    Ctrl+B, [, then Up or Down.
