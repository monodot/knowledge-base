---
layout: page
title: Java Logging - SLF4J, etc.
---

## Troubleshooting

```
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
SLF4J: Defaulting to no-operation (NOP) logger implementation
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
```

- This is because the SLF4J APIs are on the classpath, but an implementation is not.
- Add an implementation, e.g.:
  - `org.slf4j:slf4j-simple:1.7.25`. This "simple" implementation just outputs all events to _System.err_, and ignores anything lower than INFO level.
  - `org.slf4j:slf4j-jdk14:1.7.25`. This uses _java.util.logging_, also known as JDK 1.4 Logging.


