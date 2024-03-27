---
layout: page
title: Thymeleaf
---

## Cookbook

### Fill an element with a templated string

Use the `|` operator - called _Literal substitutions_ in Thymeleaf:

```
<div th:text="|Poll type: ${poll.type}|"></div>
```

- You can only use variable expressions here - e.g. `${..}`
- You can't use conditional expressions, booleans, etc.
