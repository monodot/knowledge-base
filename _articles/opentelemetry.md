---
layout: page
title: OpenTelemetry
lede: Vendor-neutral telemetry for infra and applications.
---

## Key things

### OTLP

- The default network port for OTLP/gRPC is **4317**
- The default network port for OTLP/HTTP is **4318**.

## Terms of art

**Sampling** is the term that describes sending a subset of your traces to your observability backend, perhaps to save costs, filter out noise or only send traces that are interesting to you:

- **Head-based sampling** is _"where the sampling decision is made at the **beginning** of a request when the root span begins processing"_
- **Tail sampling** is _"where the sampling decision is made **after** all the spans in a request have been completed"_

