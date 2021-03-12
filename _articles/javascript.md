---
layout: page
title: JavaScript
---

Mi JavaScripts.

{% include toc.html %}

## Variables

### Declaring variables

For modern JavaScript:

- `let` to declare a variable in modern JavaScript (ES6 or later)
- `const` for values that must not change, or that you want to throw an error if they are changed.

For JavaScript before ES6:

- `var` - to declare a variable in versions of JavaScript before ES6.
  - `var` variables do not have block scope.
  - They are scoped to the body of the containing function.
  - If `var` is used outside a function body, it declares a global variable.

## Troubleshooting

| Problem | Cause | Solution |
| ------- | ----- | -------- |
| jQuery can't find plugins: _"TypeError: xxxxx is not a function"_ | jQuery is being loaded twice. | Remove the second jQuery. |
