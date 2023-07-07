---
layout: page
title: mitmproxy
---

An awesome way to debug HTTP connections in any application, including HTTPS/SSL.

## Basics

### Setup on Fedora with SSL

1.  Install mitmproxy
1.  Run `mitmproxy`
1.  Copy the source certificate: `sudo cp ~/.mitmproxy/mitmproxy-ca-cert.cer /etc/pki/ca-trust/source/anchors/`
1.  Regenerate your system certificates: `sudo update-ca-trust`
1.  `export HTTP_PROXY=localhost:8080 && export HTTPS_PROXY=localhost:8080`
1.  Start your program and profit.

### Set up on Debian with SSL certificate

1.  `apt install mitmproxy`
2.  Run `mitmproxy` (preferably as root)
3.  Copy the source certificate: `cp ~/.mitmproxy/mitmproxy-ca-cert.cer /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt`
4.  Regenerate your system certificates: `sudo update-ca-certificates`
5.  `export HTTP_PROXY=localhost:8080 && export HTTPS_PROXY=localhost:8080`
6.  Start your program and profit.

### Browse/read a mitmproxy dump file

Start mitmproxy to read/browser a previously-created dump file, without starting a proxy server:

```
mitmproxy --rfile <dumpfile> --no-server
```

## Spying on traffic from a Kubernetes app

One use case for mitmproxy is to inspect traffic from a Kubernetes app. This is quite useful when black-box troubleshooting a third-party component or app!

1.  Install and run mitmproxy locally, and let it generate its SSL certificates.

2.  Add the certificates it generates into a Secret:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: mitmproxy-tls
    type: Opaque
    stringData:
      mitmproxy-ca.pem: |
        -----BEGIN PRIVATE KEY-----
        MIIE....
        -----END CERTIFICATE-----
      mitmproxy-dhparam.pem: |
        -----BEGIN DH PARAMETERS-----
        MIICC....
        -----END DH PARAMETERS-----
    ```

3.  Deploy mitmproxy in dump mode (`mitmdump`), ensuring it saves requests into a dump file:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: mitmproxy
    spec:
      replicas: 1  
      selector:
        matchLabels:
          app.kubernetes.io/instance: mitmproxy
      template:
        metadata:
          labels:
            app.kubernetes.io/instance: mitmproxy
        spec:
          containers:
          - name: proxy
            image: docker.io/mitmproxy/mitmproxy:latest
            imagePullPolicy: IfNotPresent
            command:
            - mitmdump
            - --set
            - confdir=/home/mitmproxy/tls
            - -w
            - /home/mitmproxy/mitmproxy.dumpfile
            resources:
              requests: 
                memory: "64Mi"
                cpu: "250m"
              limits:
                memory: "128Mi"
                cpu: "500m"
            readinessProbe:
              tcpSocket:
                port: http
              initialDelaySeconds: 5
              periodSeconds: 10
            ports:
            - name: http
              containerPort: 8080
              protocol: TCP
            volumeMounts:
            - name: tls
              mountPath: /home/mitmproxy/tls
          volumes:
          - name: tls
            secret:
              secretName: ratelimiter-tls
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: mitmproxy
    spec:
      selector:
        app.kubernetes.io/instance: mitmproxy
      ports:
      - port: 8080
        targetPort: 8080
    ```

4.  Mount or bake mitmproxy's certificate into your application's container image, e.g.:

    ```Dockerfile
    COPY certs/mitmproxy.crt /usr/local/share/ca-certificates/mitmproxy.crt
    # Where "mitmproxy.crt" should contain "-----BEGIN CERTIFICATE-----..."

    RUN update-ca-certificates
    ```

5.  Deploy your application and configure it to use mitmproxy as a proxy, e.g. set these env vars on your application's Deployment:

    ```yaml
    env:
    - name: http_proxy
      value: "http://mitmproxy:8080"
    - name: https_proxy
      value: "http://mitmproxy:8080"
    ```

6.  Perform some actions in your application. Once you've captured enough traffic and you're ready to inspect the dump file, take a local copy of the dump file from the Pod, and open it locally with _mitmproxy_:

    ```shell
    kubectl -n qadwa-jobs cp $(kubectl -n NAMESPACE get pod --selector app.kubernetes.io/instance=mitmproxy -oname | cut --delimiter="/" --fields=2):/home/mitmproxy/mitmproxy.dumpfile mitmproxy.dumpfile

    mitmproxy --rfile mitmproxy.dumpfile --no-server
    ```

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
