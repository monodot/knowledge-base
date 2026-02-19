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

opentelemetry-lambda:

- See https://github.com/open-telemetry/opentelemetry-lambda/releases
- ARNs like:
  - `arn:aws:lambda:<region>:184161586896:layer:opentelemetry-javaagent-0_17_0:1`
  - `arn:aws:lambda:<region>:184161586896:layer:opentelemetry-nodejs-0_19_0:1`
  - `arn:aws:lambda:<region>:184161586896:layer:opentelemetry-collector-<amd64|arm64>-0_12_0:1` (a stripped-down version of OTel Collector inside an AWS Extension Layer)

ADOT (AWS Distribution of OpenTelemetry):

- ADOT is a **downstream repo of opentelemetry-lambda**
- AWS-managed OpenTelemetry Lambda layers that are preconfigured for use with AWS services and bundle the reduced ADOT Collector
- ARNs like:
  - `arn:aws:lambda:ca-central-1:901920570463:layer:aws-otel-nodejs-amd64-ver-1-18-0:1` - "legacy" layer which includes an embedded collector.
  - `arn:aws:lambda:eu-central-1:615299751070:layer:AWSOpenTelemetryDistroPython:21` - new-style layer which works with CloudWatch **only**. 

