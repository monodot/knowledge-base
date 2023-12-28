---
layout: page
title: Vue.js
---

## Related projects

- **Vite** is a build tool for Vue.js. It's a replacement for Webpack.

## Examples

### Using `json-editor` with Vue.js and Tailwind

Building a JSON editor using the `json-editor` library and Tailwind.

In the `<template>` block, create a div and use `ref` to give it an ID:

```html
<div ref="jsoneditor"></div>
<button v-on:click="writeLog">Submit (console.log)</button>
<pre v-text="outputJson" class="font-mono border py-2 px-3 shadow bg-white"></pre>
```

Then, in the `<script>` block, import JSONEditor, create an object `editor` which will hold the `JSONEditor` object, use Vue's mounted event to create the editor, and bind an on-change event to update the code in the `pre` element when the form values are changed:

```js
import { JSONEditor } from '@json-editor/json-editor/dist/jsoneditor.js'

export default {
  name: 'Example',
  props: {
    msg: String
  },
  data() {
    return {
      // The 'editor' object becomes part of the component's data structure...
      editor: null
    }
  },
  methods: {
    // When the button is clicked, write the JSON to the console
    writeLog: function() {
      console.log(this.editor.getValue())
    }
  },
  computed: { },
  mounted() {
    // Taking inspiration from: https://github.com/Adam-Jimenez/vue2-jsoneditor/blob/master/src/components/JsonEditor.vue
    // Use this.$refs to reference our empty json-editor div element by its ID
    const container = this.$refs.jsoneditor

    // Create a new instance of the JSONEditor, and supply our json-schema.
    this.editor = new JSONEditor(container, {
      schema: {
        "title": "Pod",
        "type": "object",
        "properties": {
          "apiVersion": {
            "type": "string",
            "options": {
              "hidden": "true"
            },
            "default": "v1"
          },
          "kind": {
            "type": "string",
            "options": {
              "hidden": "true"
            },
            "default": "Pod"
          },
          "metadata": {
            "type": "object",
            "properties": {
              "name": {
                "type": "string",
                "default": "my-pod-0"
              }
            }
          },
        }
      },
      theme: 'tailwind'
    })

    // When the
    this.editor.on('change', function() {
      var json = this.getValue()
      this.outputJson = JSON.stringify(json, null, 2)
    })
  }
}
```

