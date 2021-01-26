---
layout: page
title: PlantUML
---

## Cheatsheet

### Lines and arrows

- `--` simple line join
- `->` arrow pointing to another object in the same level (e.g. right)
- `-->` arrow to an object in the next "level" in the diagram, or `-down->`
- `-right->`, `-left->`, `-up->` and `-down->` for specific direction arrows

### Mindmaps in Markdown

```
@startmindmap
* root node
	* some first level node
		* second level node
		* another second level node
	* another first level node
@endmindmap
```

### Direction

The default behaviour for a diagram is **top to bottom**. Change this to **left to right** using:

    left to right direction

### Icons

Plantuml uses _Openiconic_ for icons, e.g. `&star`, `&graph`, `&people`, etc.

See <https://useiconic.com/open/> for the full list of icons.



