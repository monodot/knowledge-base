---
layout: page
title: Bash pipelines
---

Faffing about with stdout, stderr, etc.

## Cookbook

### Pipe stdout and (additionally) stderr to a command

Some commands write their output to stderr. This might be the case if you're getting logs from a Docker container and the program inside is writing to stderr.

To pipe both stdout and stderr somewhere else, use one of these:

```
mycommand |& mysecondcommand

mycommand 2>&1 | mysecondcommand
```


## Troubleshooting

I am piping a command to 'grep' to search its output, but I'm getting the whole output instead of just the lines I want:

- The regular pipe character just pipes stdout to your next command.
- Maybe the first command in your pipeline is actually writing to _stderr_
- Use the cookbook entry above to additionally pipe stderr to your next command.


