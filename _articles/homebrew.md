---
layout: page
title: Homebrew
---

The package manager for OS X.

## Concepts

- **keg-only** - means it is not symlinked into `/usr/local`

## Configuration

Applications and where their configuration is located:

- **Nexus:**
    - Sonatype Work directory (for repository configuration, etc.): `/usr/local/var/nexus`

## Troubleshooting

**Mac OS X Mojave - xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools), missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun**

- Open Terminal and run `xcode-select --install` [1][1]


[1]: https://apple.stackexchange.com/questions/254380/macos-mojave-invalid-active-developer-path


