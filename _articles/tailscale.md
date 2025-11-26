---
layout: page
title: Tailscale
---

## Basic administration

### Start tailscale

```sh
sudo tailscale up
```

## GitHub Actions workflow example

You'll need to add a couple of sections like this to your Tailscale ACL, assuming you're tagging your GitHub OAuth client with `tag:ci` and your server with `tag:server`:

```json
	// Define the tags which can be applied to devices and by which users.
	"tagOwners": {
		"tag:ci":     ["autogroup:admin"],
		"tag:server": ["autogroup:admin"],
	},

    // Define users and devices that can use Tailscale SSH.
	"ssh": [
		{
			"action": "accept",
			"src":    ["tag:ci"],
			"dst":    ["tag:server"],
			"users":  ["root"],
		},
	],
```

Then this example workflow should work (example hostname here is `vinson`):

```yaml
name: CI

on:
  push:
    branches: [ $default-branch ]
  pull_request:
    branches: [ $default-branch ]
  workflow_dispatch:

jobs:

  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Tailscale
        uses: tailscale/github-action@v3
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci  # OAuth clients are not associated with any user in a tailnet, so they require at least one tag.

      - name: check for vinson.ts.net in netmap
        shell: bash
        run:
          tailscale status | grep -q vinson

      - name: Attempt to run command on vinson
        shell: bash
        run: |
          mkdir -p ~/.ssh
          ssh-keyscan -H vinson >> ~/.ssh/known_hosts
          ssh root@vinson cat /etc/system-release
```

