---
layout: page
title: Tmux - terminal multiplexer
---

_tmux_ is a terminal multiplexer - it lets you work in multiple terminal (pseudo-)windows, inside the same terminal session.

Terminology:

- The **prefix key** is the key combination that is always given before issuing a **command** in _tmux_. **Usually the prefix key is Ctrl+b**
- **Session** is a single collection of terminals under the management of _tmux_.
- A **pane** is the individual split terminal that you see on one screen.
- A **window** in tmux is basically a tab, or a collection of **panes**.

To find out what the prefix-key is set as:

    tmux list-keys

    # or, within a tmux session, type (prefix-key) + ? to see key configurations

Quit a terminal session within Tmux:

    <Ctrl+D>

## Tmux basics

Launch _tmux_:

    tmux

Get help within _tmux_ (quick keyboard shortcut reference):

    Ctrl+b, ?
    then 'q' to exit the help screen

### Creating new panes

Create a new horizontal pane (split into two, left and right):

    Ctrl+b, %

Create a vertical pane (split into two, top and bottom):

    Ctrl+b, "

### Working with panes

Resize a pane taller or shorter:

    Ctrl+b, Ctrl+(Up or Down key)

Scroll within a pane:

    Ctrl+b, [, then Up or Down.

### To scroll back within a pane

If you want to see the previous buffer within a pane, you can enter **copy mode** which basically lets you scroll back through the buffer:

    Ctrl+b, Page Up

You'll also see a label at the top right, showing your position within the buffer, e.g. `[29/1910]`

Press `q` to exit copy mode.
