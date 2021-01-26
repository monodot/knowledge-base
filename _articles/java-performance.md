---
layout: page
title: Java Performance
---

Two important things in the Java performance engineer's arsenal:

- Thread dump - analyse using [Thread Dump Analyzer][tda], or in realtime using VisualVM.
- Heap dump - analyse using [Eclipse Memory Analyzer][mat].

## Cookbook

To capture a thread dump:

    jstack -l <JAVA_PID>

To capture a heap dump file (to browse the heap dump, you can use `jhat` (Java Heap Analysis Tool)):

    jmap -dump:format=b,file=heap.hprof JAVA_PID
    # creates a file named heap.hprof

## Diagnosis

### What's causing high CPU?

To check what might be causing high CPU, capture a thread dump of the Java process in question, for example by using `jstack` at regular intervals, e.g. every 30 seconds. Then analyse the thread dump(s) using a tool like [Thread Dump Analyzer][tda].

### Get information about threads

Use `ps -eLF` to get information about all threads, e.g. `ps -eLF | grep <pid> | wc -l` will count the number of threads for a PID.

### What's causing threads to be stuck in park()

`park()` causes a thread to be placed into a waiting state.




[tda]: https://github.com/irockel/tda
[mat]: http://www.eclipse.org/mat/
