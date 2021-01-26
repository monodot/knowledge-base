---
layout: page
title: Node
---

The Javascripts.

## Installation on Fedora

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

    $ npm use 8.1
    Now using node v8.1.2 (npm v5.0.3)

## Package management using npm

### Installing packages globally

To install packages globally, without having to use `sudo`, [change the install location][mb] and add `~/.local/bin` to `PATH`:

    npm config set prefix ~/.local
    PATH=~/.local/bin/:$PATH  

Then you can install packages globally using:

    npm install --global smee-client

###

A typical `package.json` file might look like this:

```json
{
  "name": "minimal-mistakes",
  "version": "4.6.0",
  "description": "Minimal Mistakes Jekyll theme npm build scripts",
  "repository": {
    "type": "git",
    "url": "git://github.com/mmistakes/minimal-mistakes.git"
  },
  "keywords": [
    "jekyll",
    "theme",
    "minimal"
  ],
  "author": "Michael Rose",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/mmistakes/minimal-mistakes/issues"
  },
  "homepage": "https://mmistakes.github.io/minimal-mistakes/",
  "engines": {
    "node": ">= 0.10.0"
  },
  "devDependencies": {
    "npm-run-all": "^1.7.0",
    "onchange": "^2.2.0",
    "uglify-js": "^2.6.1"
  },
  "scripts": {
    "uglify": "uglifyjs assets/js/vendor/jquery/jquery-3.2.1.min.js assets/js/plugins/jquery.fitvids.js assets/js/plugins/jquery.greedy-navigation.js assets/js/plugins/jquery.magnific-popup.js assets/js/plugins/jquery.smooth-scroll.min.js assets/js/_main.js -c -m -o assets/js/main.min.js",
    "add-banner": "node banner.js",
    "watch:js": "onchange \"assets/js/**/*.js\" -e \"assets/js/main.min.js\" -- npm run build:js",
    "build:js": "npm run uglify && npm run add-banner"
  }
}
```

## Troubleshooting

| Problem | Cause | Solution |
| ------- | ----- | -------- |
| _"SyntaxError: Unexpected token &gt;"_, when parsing a line containing the token `=>` | This is an [Arrow Function][arrowfunctions], part of the ECMAScript 6 standard. This only became part of Node from v4.0.0. | Upgrade your Node to a version that supports ECMAScript 6+. |


[arrowfunctions]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions
[mb]: http://michaelb.org/the-right-way-to-do-global-npm-install-without-sudo/
