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

## Updating packages

First check to see what's "outdated":

```
$ npm outdated
Package            Current   Wanted   Latest  Location                        Depended by
@babel/core         7.16.0  7.22.11  7.22.11  node_modules/@babel/core        public
@babel/preset-env   7.16.0  7.22.10  7.22.10  node_modules/@babel/preset-env  public
autoprefixer        10.4.0  10.4.15  10.4.15  node_modules/autoprefixer       public
browser-sync        2.27.7   2.29.3   2.29.3  node_modules/browser-sync       public
gulp-purgecss        4.0.3    4.1.3    5.0.0  node_modules/gulp-purgecss      public
postcss             8.3.11   8.4.28   8.4.28  node_modules/postcss            public
tailwindcss         2.2.19   2.2.19    3.3.3  node_modules/tailwindcss        public
```

And then:

```
$ npx -p npm-check-updates ncu -u 
```

## How to 'run' a package on its own (e.g. for debugging packages)

If you want to run a binary/package then you can use the symlink in `node_modules/.bin`, or the use the _npx_ command, which works whether you've already installed the package into your project (with _npm install mypackage_) or not.

For example, to install the _rollup_ package, and then execute it:

```
npm install rollup --save-dev
npx rollup --config

# or, use the symlink:
./node_modules/.bin/rollup --config
```

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

