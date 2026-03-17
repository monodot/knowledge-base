---
layout: page
title: OpenTelemetry eBPF Instrumentation (Beyla)
---

## Instrumentation types

OBI can instrument in one of these ways:

- **eBPF**: instruments network calls using eBPF.
  - This is disabled by default, you need to enable it.

- **Java Agent injector** (`javaagent.Injector` in the logs)

- **Node.js injector** (`nodejs.Injector` in the logs)

## Context propagation

- **Black box context propagation:** where Beyla maintains a map of which services are talking to each other.

- **ebpf.context_propagation:** where Beyla injects context into actual requests, via:
  - HTTP traceparent: a header is set on outgoing requests
  - TCP header options (the receiving end also needs a Beyla instance to decode it)

## Log clues

What to look for in the logs.

Injecting an agent into a Java process:

```
time=2026-03-15T22:01:04.184Z level=INFO msg="injecting OpenTelemetry eBPF instrumentation for Java process" component=javaagent.Injector pid=769073
time=2026-03-15T22:01:05.551Z level=INFO msg="instrumenting process" component=discover.traceAttacher cmd=/opt/java/openjdk/bin/java pid=769073 ino=11018437 type=java service="" logenricher=false
```

Injecting an agent into a Node.js process:

```
time=2026-03-15T22:01:03.722Z level=INFO msg="loading NodeJS instrumentation" component=nodejs.Injector pid=769241
time=2026-03-15T22:01:03.927Z level=INFO msg="instrumenting process" component=discover.traceAttacher cmd=/usr/local/bin/node pid=769241 ino=11032542 type=nodejs service="" logenricher=false
```

Instrumenting an nginx instance:

```
time=2026-03-15T22:01:03.541Z level=DEBUG msg="finding library" component=ebpf.Instrumenter probes=uprobes lib=nginx
time=2026-03-15T22:01:03.542Z level=DEBUG msg="nginx not linked, attempting to instrument executable" component=ebpf.Instrumenter probes=uprobes path=/proc/768505/exe
time=2026-03-15T22:01:04.154Z level=INFO msg="instrumenting process" component=discover.traceAttacher cmd=/usr/sbin/nginx pid=769319 ino=11093419 type=generic service="" logenricher=false
```

Trace from a SQL statement (assuming you have set `BEYLA_TRACE_PRINTER=text`):

```
2026-03-15 22:01:08.3151018 (989.161µs[989.161µs]) SQLClient(subType=2) 0 SELECT products [10.89.0.5 as postgres:41566]->[10.89.0.2 as 10.89.0.2:5432] contentLen:94B responseLen:0B svc=[postgres cpp] traceparent=[00-f13584eee55675eb94b9131e91c9a0c7-32889dc5829018f9[0000000000000000]-00]
```

Instrumenting a Java process from a port, without the agent:

```
time=2026-03-16T11:58:24.633Z level=DEBUG msg="found process" component=discover.CriteriaMatcher pid=862873 comm=/opt/java/openjdk/bin/java metadata=map[] podLabels=map[] criteria=[0xc0005ca090] logEnricherCriteria=[]
time=2026-03-16T11:58:24.682Z level=DEBUG msg="found an instrumentable process" component=discover.ExecTyper UID="{Name:java-otel-server Namespace: Instance:}" type=java exec=/opt/java/openjdk/bin/java pid=862873

time=2026-03-16T11:27:19.125Z level=DEBUG msg="found an instrumentable process" component=discover.ExecTyper UID="{Name:java-otel-server Namespace: Instance:}" type=java exec=/opt/java/openjdk/bin/java pid=844896
time=2026-03-16T11:27:20.765Z level=INFO msg="instrumenting process" component=discover.traceAttacher cmd=/opt/java/openjdk/bin/java pid=844896 ino=11018437 type=java service=java-otel-server logenricher=false
time=2026-03-16T11:27:20.766Z level=DEBUG msg="reusing Generic tracer for" component=discover.traceAttacher pid=844896 child=[] cmd=/opt/java/openjdk/bin/java language=java
time=2026-03-16T11:27:20.767Z level=DEBUG msg="running tracer for new process" component=beyla.Instrumenter inode=11018437 pid=844896 exec=/opt/java/openjdk/bin/java
```

