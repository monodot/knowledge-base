---
layout: page
title: SvelteJS
---

## Cookbook

### Write a log line when a variable changes

```
$: console.log(`the value of myvar is now: ${myvar}`);
```

### Setting multiple CSS classes dynamically

Use a ternary expression if you need to set multiple CSS classes dynamically n an element:

    <button type="button" class="class-1 class-2 ....
        {isAvailable ? 'is-available is-very-available' : 'is-not-available'}">

### Calling a function with arguments, on an event

For example - invoking some code whenever a button is clicked.

You can't specify the function in the click handler directly, because it will be invoked immediately. Instead, use an **arrow function with no arguments**. The function will only be invoked when the click event happens:

    <button on:click|preventDefault={() => handleClick("foo", "bar")}>
      Click Me!
    </button>

And then the function would be defined as:

    function handleClick(arg1, arg2) {
        // Do stuff here...
    }


## Troubleshooting

### Server quits immediately when using `rollup-plugin-dev`

- Dev server seems to exit immediately with a message like: _[2021-05-15 11:06:37] waiting for changes..._
- Check whether another process is already running on the same port. If so, the server start might fail silently like this.


