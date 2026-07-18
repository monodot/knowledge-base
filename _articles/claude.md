---
layout: page
title: Claude
lede: Claude, Claude Code and all the other billions of flavours.
---

## Claude Code

### Claude Code permanent session setup on MacOS

How to set up a single, always-on Claude Code session on MacOS, with remote control:

```sh
screen -S claude

cd /path/to/your/project
cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/   # for iCloud Drive folders

claude --remote-control  # start a single session and expose via Remote Control on the web
claude remote-control    # start in server mode, allow Claude Code on the Web to create new sessions
```

Reattach to an existing session (e.g. over SSH) - e.g. to fix a broken remote-control connection:

```sh
screen -r claude
# Then run `/remote-control` in the Claude Code session
# To detach - Ctrl-a d
```
