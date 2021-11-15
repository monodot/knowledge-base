---
layout: page
title: TailwindCSS
---

The CSS framework.

## Adding Tailwind into a project

Here are the high level steps:

1. Add `tailwindcss` to your project using `npm install tailwindcss`.

2. Configure Tailwind as you need it, with _tailwind.config.js_.

3. Add `tailwindcss` as a PostCSS plugin, by adding it into _postcss.config.js_. This means that PostCSS will "run" tailwindcss when it's processing your CSS.

4. Call PostCSS from your build tool (like Gulp, or whatever).

## Example tailwind.config.js

```js
const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
    purge: {
       content: ['./src/main/resources/templates/**/*.html']
    },
    darkMode: false, // or 'media' or 'class'
    theme: {
        extend: {
            fontFamily: {
                sans: ['Inter var', ...defaultTheme.fontFamily.sans],
            }
        },
    },
    variants: {
        extend: {},
    },
    plugins: [],
}
```

## Purging unused classes

_(Writing this down, because the whole process baffles me right now.)_

Use the _tailwindcss_ module. It will purge unused classes, to make your final output CSS file smaller, **but only if it detects that you are running a production build, e.g. <u>if the environment variable `NODE_ENV` is set to `production`</u>.**

You can see this manually, using the tailwind CLI:

```
NODE_ENV=production npx tailwindcss -o tailwind.css
```

This command will read your _tailwind.config.js_ file, and should produce an output file _tailwind.css_ which contains only the classes which you have referenced.

You can make this file even smaller by **minifying it**, using the argument `--minify`:

```
NODE_ENV=production npx tailwindcss -o tailwind.css --minify
```


