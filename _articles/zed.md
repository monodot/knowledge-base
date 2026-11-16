---
layout: page
title: Zed
---

Really confusing text editor.

## Threads

Zed has a threads sidebar, which can show:

- **Terminal threads:** Zed opens a regular terminal, and lists it in the Threads sidebar. You run `claude` (CLI) yourself. You can use things like `/add-dir` (in Claude Code)
- **Claude Agent thread:** Zed connects to Claude through ACP. It uses Claude's agent code, and Zed draws the UI. It will be missing some Claude Code features, like `/add-dir`.
- **Zed agent thread:** Agent that's built in to Zed. You choose the underlying model via API key. Allows you to swap out Anthropic/OpenAI/etc.

## Running multiple Claude Code terminal sessions

If you want to use Zed as a way to manage multiple Claude Code **terminal** sessions:

1.  Open the **Agent Panel** (View -> Agent Panel). Or from the command palette, run **agent: toggle focus**.
2.  In the project dropdown at the top, choose the project you want to work in.
3.  Click the **+** (new thread) button, then from the context menu, choose **Terminal**.

See: https://zed.dev/docs/ai/terminal-threads
