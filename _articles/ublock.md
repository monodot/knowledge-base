---
layout: page
title: uBlock
---

Filtering rules and stuff.

## Rule to filter out the "Login with Google" box

This box is annoying as fuck and a dark UX pattern (whether intentional or not). It usually appears on top of a site's normal login button, trying to convince you to log in with Google. Kill it:

```
* accounts.google.com * block
```

