---
layout: page
title: Trufflehog
---

Scan for secrets and things.

## Quick installation

```sh
gh release download --repo trufflesecurity/trufflehog --pattern '*linux_amd64*.tar.gz' --dir /tmp 

tar -xzf /tmp/trufflehog_*_linux_amd64.tar.gz -C /tmp

sudo mv /tmp/trufflehog /usr/local/bin/trufflehog
```

