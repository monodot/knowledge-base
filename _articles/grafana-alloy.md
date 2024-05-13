---
layout: page
title: Grafana Alloy
---

Grafana Alloy is an OpenTelemetry Collector distribution with programmable pipelines.

## Configurations

### Wildfly 10 with Otel Java Agent to Grafana Cloud

Collect telemetry from Wildfly 10 with the OpenTelemetry Instrumentation for Java agent, and then push the telemetry, via Grafana Alloy, to Grafana Cloud:

1.  Configure and install Grafana Alloy (on Fedora/RHEL):

    ```shell
    curl -OL https://github.com/grafana/alloy/releases/download/v1.0.0/alloy-1.0.0-1.amd64.rpm
    sudo dnf install alloy-1.0.0-1.amd64.rpm

    rpm --query --list --provides alloy-1.0.0-1.amd64.rpm

    sudo rpm -i alloy-1.0.0-1.amd64.rpm
    ```

2.  Pass OTLP/Grafana endpoint details to Alloy by setting environment variables in the systemd unit directly:

    ```shell
    export OTLP_ENDPOINT=https://otlp-gateway-__REGION__.grafana.net:443/otlp
    export BASIC_AUTH_USER="___0___"
    export API_KEY="glc_eyJ......"

    sudo mkdir -p /etc/systemd/system/alloy.service.d

    sudo touch /etc/systemd/system/alloy.service.d/environment.conf

    sudo tee -a /etc/systemd/system/alloy.service.d/environment.conf << EOF
    [Service]
    Environment="OTLP_ENDPOINT=${OTLP_ENDPOINT}"
    Environment="API_KEY=${API_KEY}"
    Environment="BASIC_AUTH_USER=${BASIC_AUTH_USER}"
    EOF

    sudo systemctl daemon-reload

    ```
    
3.  Add OTLP components to the default Alloy configuration file, and then restart.

    ```shell
    sudo tee -a /etc/alloy/config.alloy << EOF

    otelcol.exporter.otlphttp "default" {
      client {
        endpoint = env("OTLP_ENDPOINT")
        auth     = otelcol.auth.basic.credentials.handler
      }
    }

    otelcol.auth.basic "credentials" {
      // Retrieve credentials using environment variables.

      username = env("BASIC_AUTH_USER")
      password = env("API_KEY")
    }

    otelcol.receiver.otlp "example" {
      grpc {
        endpoint = "127.0.0.1:4317"
      }

      http {
        endpoint = "127.0.0.1:4318"
      }

      output {
        metrics = [otelcol.exporter.otlphttp.default.input]
        logs    = [otelcol.exporter.otlphttp.default.input]
        traces  = [otelcol.exporter.otlphttp.default.input]
      }
    }
    EOF

    sudo systemctl restart alloy
    ```

1.  Download and start Wildfly with the OpenTelemetry Java agent attached:

    ```shell
    curl -OL https://download.jboss.org/wildfly/10.0.0.Final/wildfly-10.0.0.Final.tar.gz

    tar xvf wildfly-10.0.0.Final.tar.gz

    cd wildfly-10.0.0.Final/

    curl -OL https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar

    export JAVA_OPTS="-javaagent:$PWD/opentelemetry-javaagent.jar"

    # Download Java 8 if you don't have it already
    curl -s "https://get.sdkman.io" | bash
    sdk install java 8.0.402-tem

    ./bin/standalone.sh
    ```

2.  Build and deploy the "kitchensink" example app:

    ```shell
    git clone https://github.com/wildfly/quickstart wildfly-quickstart
    cd wildfly-quickstart
    git checkout 10.x

    cd kitchensink
    mvn wildfly:deploy
    ```

1.  Visit http://localhost:8080/wildfly-kitchensink/ in a web browser and make some requests. Or, use the REST API:

    ```shell
    curl -v -H 'Content-type: application/json' -X POST http://localhost:8080/wildfly-kitchensink/rest/members -d '{ "name": "Benny", "email": "benny@example.com", "phoneNumber": "447999332451" }'
    ```

From this, you should get some useful out-of-the-box metrics, logs and traces in Grafana Cloud:

- Metrics
  - `http_server_request_duration_seconds_count` (and _bucket and _sum) - e.g. `http_server_request_duration_seconds_sum{http_route="/wildfly-kitchensink/rest/members/{id:[0-9][0-9]*}"}`
  - `jvm_cpu_count`
  - `jvm_memory_limit_bytes`, `jvm_memory_committed_bytes`
  - `target_info` -- an "info" style metric, with info like process PID, command line, OS version, etc
- Logs: you'll also get some **logs** with OpenTelemetry resource attributes
- Traces: e.g. search for service name "JBoss Modules"

## Example configs

### Namespace-scoped Role and RoleBinding

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: grafana-agent
  namespace: myapp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: grafana-agent
  namespace: myapp
rules:
- apiGroups:
  - ""
  resources:
  - services
  - endpoints
  - pods
  - events
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: grafana-agent
  namespace: myapp
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: grafana-agent
subjects:
- kind: ServiceAccount
  name: grafana-agent
  namespace: myapp
```

## Troubleshooting

### Metrics do not appear in Grafana Cloud

- Check that the Agent is running and that the Service/Pod is healthy.
- Check the list of endpoints that the Agent has discovered and is scraping. Port-forward to the Agent and use the HTTP API to list the discovered targets:
    - `kubectl -n <namespace> port-forward grafana-agent-0 8001:80`
    - `curl localhost:8001/agent/api/v1/metrics/targets`
- If the targets list is empty, something is wrong:
    - Make sure that the Agent has permissions to view pods and services in the cluster (e.g. with a RoleBinding)
    - If scraping a single namespace (or just a few), make sure that the Agent is configured to do so:

```yaml
    kubernetes_sd_configs:
        - role: pod
        namespaces:
            names:
            - <NAMESPACE>
```



Paddle rate limit bump:

https://github.com/grafana/deployment_tools/pull/141482

> May 13 20:00:42 dougal alloy[4107177]: ts=2024-05-13T19:00:42.059766768Z level=error msg="Exporting failed. Dropping data." component_path=/ component_id=otelcol.exporter.otlp.default error="no more retries left: rpc error: code = Unavailable desc = connection error: desc = \"transport: Error while dialing: dial tcp: lookup otlp-gateway-prod-gb-south-0.grafana.net/otlp: no such host\"" dropped_items=35

