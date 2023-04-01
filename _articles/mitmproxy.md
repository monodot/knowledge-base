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

## Set up on Debian with SSL certificate

1.  `apt install mitmproxy`
2.  Run `mitmproxy` (preferably as root)
3.  Copy the source certificate: `cp ~/.mitmproxy/mitmproxy-ca-cert.cer /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt`
4.  Regenerate your system certificates: `sudo update-ca-certificates`
5.  `export HTTP_PROXY=localhost:8080 && export HTTPS_PROXY=localhost:8080`
6.  Start your program and profit.

## Scripting mitmproxy

### Adding a delay to all requests

```python
import logging
import time
from mitmproxy import http
import os

# Helper script for 'mitmproxy' which adds a delay to all requests to 'example.com'
#
# To use it, run 'mitmproxy -s <script.py>'

class Delayer:
    def __init__(self):
        self.filter = "example.com"
        self.delay = 2
        self.num = 0
        
    def request(self, flow: http.HTTPFlow) -> None:
        self.num = self.num + 1
        logging.info("We've seen %d flows" % self.num)

        logging.info("Sleeping for %d seconds" % self.delay)
        time.sleep(self.delay)

addons = [Delayer()]
```

### Adding a rate-limit to requests

```python
from mitmproxy import http
import logging
import time

# Helper script for 'mitmproxy' which adds a sliding window rate limit
# for all requests to 'example.com'
#
# To use it, run 'mitmproxy -s <script.py>'

class RateLimiter:
    def __init__(self):
        self.filter = "example.com"
        self.window_size = 10   # seconds
        self.max_requests = 3   # requests
        self.request_times = [] # holds timestamps of requests

    def allow_request(self):
        """
        Returns True if the request should be allowed, False otherwise.
        """
        now = time.time()
        self.request_times.append(now)
        self.request_times = [t for t in self.request_times if t > now - self.window_size]
        return len(self.request_times) <= self.max_requests

    def request(self, flow: http.HTTPFlow) -> None:
        if (self.filter != flow.request.host) or self.allow_request():
            logging.info(f"Request allowed")
        else:
            logging.info(f"Request rejected")
            flow.response = http.Response.make(429)
            return

addons = [RateLimiter()]
```
