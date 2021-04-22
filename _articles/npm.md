---
layout: page
title: npm
---

## Getting started

Create a package.json file:

    npm init

## Installing packages globally

To install packages globally, without having to use `sudo`, [change the install location][mb] and add `~/.local/bin` to `PATH`:

    npm config set prefix ~/.local
    PATH=~/.local/bin/:$PATH  

Then you can install packages globally using:

    npm install --global smee-client

## Typical package.json

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
