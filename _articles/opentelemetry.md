---
layout: page
title: OpenTelemetry
lede: Vendor-neutral telemetry for infra and applications.
---

## Key things

### OTLP

- The default network port for OTLP/gRPC is **4317** - `http://localhost:4317` and `grpc`
- The default network port for OTLP/HTTP is **4318** - `http://localhost:4318` and `http/protobuf` or `http/json`

## Terms of art

**Sampling** is the term that describes sending a subset of your traces to your observability backend, perhaps to save costs, filter out noise or only send traces that are interesting to you:

- **Head-based sampling** is _"where the sampling decision is made at the **beginning** of a request when the root span begins processing"_
- **Tail sampling** is _"where the sampling decision is made **after** all the spans in a request have been completed"_

## Lambdas/serverless

We can inspect what's inside each Lambda layer like this:

```shell
URL=$(aws lambda get-layer-version --layer-name $LAYER_ARN \
  --version-number $LAYER_VERSION \
  --query 'Content.Location' \
  --region us-east-1 --output text) \
  && curl -s "$URL" -o /tmp/layer.zip && unzip -l /tmp/layer.zip
```

### OpenTelemetry instrumentation Layer (upstream)

- Repo: <https://github.com/open-telemetry/opentelemetry-lambda/releases>
- Example ARNs:
  - `arn:aws:lambda:<region>:184161586896:layer:opentelemetry-javaagent-0_17_0:1`
  - `arn:aws:lambda:<region>:184161586896:layer:opentelemetry-nodejs-0_19_0:1`

Contents:

```shell
export LAYER_ARN=arn:aws:lambda:us-east-1:184161586896:layer:opentelemetry-javaagent-0_17_0
export LAYER_VERSION=1
```

Gives:

```terminaloutput
  Length      Date    Time    Name
---------  ---------- -----   ----
     1164  11-27-2025 17:55   otel-handler
 23942900  11-27-2025 14:16   opentelemetry-javaagent.jar
---------                     -------
 23944064                     2 files
```

### OpenTelemetry Collector layer (upstream)

- Example ARN: `arn:aws:lambda:<region>:184161586896:layer:opentelemetry-collector-amd64-0_12_0:1`
- A stripped-down version of OTel Collector inside an AWS Extension Layer
- Lambda looks for extensions in the `/opt/extensions/` directory, interprets each file as an executable bootstrap for launching the extension
- In this layer, there is an extension, `extensions/collector`, a ~50Mb binary.

Contents:

```terminaloutput
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  11-12-2024 21:11   collector-config/
      375  11-12-2024 21:11   collector-config/config.yaml
        0  11-12-2024 21:11   extensions/
 43831448  11-12-2024 21:11   extensions/collector
---------                     -------
 43831823                     4 files
```

### AWS Distro for OpenTelemetry (ADOT)

- https://github.com/aws-observability/aws-otel-lambda
- ADOT is a **downstream repo of opentelemetry-lambda**
- Bundles a trimmed-down version of ADOT Collector
- AWS-managed OpenTelemetry Lambda layers that are preconfigured for use with AWS services and bundle the reduced ADOT Collector
- ARNs like:
  - `arn:aws:lambda:ca-central-1:901920570463:layer:aws-otel-nodejs-amd64-ver-1-18-0:1` - "legacy" layer which includes an embedded collector.
  - `arn:aws:lambda:us-east-1:615299751070:layer:AWSOpenTelemetryDistroJava:9` - new-style layer which works with CloudWatch **only**. 

#### Layer with Collector embedded

```shell
export LAYER_ARN=arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-java-agent-amd64-ver-1-32-0
export LAYER_VERSION=6
```

Gives:

```terminaloutput
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  05-29-2025 21:21   collector-config/
      364  05-29-2025 21:21   collector-config/config.yaml
        0  05-29-2025 21:21   extensions/
 42049720  05-29-2025 21:21   extensions/collector
 23958345  05-29-2025 21:21   opentelemetry-javaagent.jar
      520  05-29-2025 21:21   otel-handler
     1164  05-29-2025 21:17   otel-handler-upstream
---------                     -------
 66010113                     7 files
```

#### New-style layer, exports OTLP directly to X-Ray by default

```shell
export LAYER_ARN=arn:aws:lambda:us-east-1:615299751070:layer:AWSOpenTelemetryDistroJava
export LAYER_VERSION=9
```

Gives:

```terminaloutput
  Length      Date    Time    Name
---------  ---------- -----   ----
 46104116  01-30-2026 20:15   aws-opentelemetry-javaagent.jar
     3074  01-30-2026 20:15   otel-instrument
---------                     -------
 46107190                     2 files
```

### [grafana/collector-lambda-extension](https://github.com/grafana/collector-lambda-extension/)

- Custom distribution of the [opentelemetry-lambda collector](https://github.com/open-telemetry/opentelemetry-lambda/tree/main/collector) layer, built for Grafana Cloud
- Designed to be used in conjunction with an opentelemetry-lambda instrumentation layer, like `arn:aws:lambda:<region>:184161586896:layer:opentelemetry-nodejs-0_19_0:1`
- ARNs like:
  - `arn:aws:lambda:us-east-1:050451360540:layer:opentelemetry-collector-grafana-arm64-v0_138_0:2`

#### What's inside

```shell
export LAYER_ARN=arn:aws:lambda:us-east-1:050451360540:layer:opentelemetry-collector-grafana-arm64-v0_138_0
export LAYER_VERSION=2
```

Gives:

```terminaloutput
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  10-29-2025 07:54   collector-config/
     1167  10-29-2025 07:54   collector-config/config.yaml
        0  10-29-2025 07:54   extensions/
 48758968  10-29-2025 07:54   extensions/collector
---------                     -------
 48760135                     4 files
```

