---
layout: page
title: Tailscale
---

## Basic administration

### Start tailscale

```sh
sudo tailscale up
```

## Using Tailscale in GitHub Actions

To reach Tailscale resources from a Github Actions workflow:

1.  Go to Settings -> Trust credentials -> Create credential. Set type to **OAuth** and set the description to something like `github-actions-REPONAME`. Set scopes to just **Keys -> Auth keys (read + write)** and set tags to **tag:ci** (or whatever tag you want your GitHub Actions runner to have)
2.  Add the ACL rules defined below.
3.  Add the Tailscale GitHub Action (example below)

### Example Tailscale ACL

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

### Example GitHub Actions workflow

Then this example workflow should work (example hostname here is `vinson`):

```yaml
{% raw %}
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
{% endraw %}
```

