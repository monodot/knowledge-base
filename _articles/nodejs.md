---
layout: page
title: Node.js
---

The Javascripts.

## Installation

### Installation on CentOS

```
dnf module install nodejs:18/common
```

Troubleshooting: _"The operation would result in switching of module 'nodejs' stream '10' to stream '18'"_

- This might happen because your CentOS enables the nodejs `10` module by default, even if you've not already installed it.
- `dnf module list --enabled` should confirm this.
- 

### Installation on Fedora

To install both npm and Node.js, run:

    $ sudo dnf install nodejs

To install additional modules from Fedora repositories:

    $ sudo dnf install nodejs-<module-name>

## Versions

Node takes a unique approach to versioning, so its version history goes something like this:

- 0.12.x
- 4.0.0 (September 2015) - this version jump marked the incorporation of _io.is_ into Node.js.
- 5.0.0 (October 2015)
- 6.0.0 (April 2016)
- 7.0.0 (October 2016)
- 8.0.0 (May 2017)
- 9.0.0 (October 2017)

### Managing versions using `nvm`

Get the current Node version:

    $ node -v
    v0.10.45
    $ nvm current
    v0.10.45

Show all installed versions using `nvm`:

    $ nvm ls
    ->     v0.10.45
             v8.1.2
    default -> v0.10 (-> v0.10.45)
    node -> stable (-> v8.1.2) (default)
    stable -> 8.1 (-> v8.1.2) (default)
    iojs -> N/A (default)

Switch to a different version using `nvm`:

    $ nvm use 8.1
    Now using node v8.1.2 (npm v5.0.3)

## Fundamentals

### Using modules

- Node.js uses _CommonJS_ syntax by default.
- This means it uses the `require`/`module.exports` syntax, and doesn't support `export` (ES6 syntax).

## Troubleshooting

| Problem | Cause | Solution |
| ------- | ----- | -------- |
| _"SyntaxError: Unexpected token &gt;"_, when parsing a line containing the token `=>` | This is an [Arrow Function][arrowfunctions], part of the ECMAScript 6 standard. This only became part of Node from v4.0.0. | Upgrade your Node to a version that supports ECMAScript 6+. |


[arrowfunctions]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions
[mb]: http://michaelb.org/the-right-way-to-do-global-npm-install-without-sudo/
