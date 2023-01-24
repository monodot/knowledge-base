---
layout: page
title: mitmproxy
---

An awesome way to debug HTTP connections in any application, including HTTPS/SSL.

## Setup on Fedora with SSL

1.  Install mitmproxy
1.  Run `mitmproxy`
1.  Copy the source certificate: `sudo cp ~/.mitmproxy/mitmproxy-ca-cert.cer /etc/pki/ca-trust/source/anchors/`
1.  Regenerate your system certificates: `sudo update-ca-trust`
1.  `export HTTP_PROXY=localhost:8080 && export HTTPS_PROXY=localhost:8080`
1.  Start your program and profit.

