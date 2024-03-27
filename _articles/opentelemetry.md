---
layout: page
title: OpenTelemetry
---

## Terms of art

**Sampling** is the term given to sending a subset of your traces to your observability backend, possibly to save costs, filter out noise or just send "interesting" traces:

- **Head-based sampling** is _"where the decision is made at the **beginning** of a request when the root span begins processing"_
- **Tail sampling** is _"where the decision to sample a trace happens **after** all the spans in a request have been completed"_

