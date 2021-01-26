---
layout: page
title: Pandoc
---

## Document classes (LaTex)

| Class name | Info               |
| ---------- | ------------------ |
| `report`   | Doesn't support subtitle. |
| `scrreprt` | Like `report`, but KOMA-Script enabled (??) Required for supporting subtitle. |


## Cookbook

Print the default LaTeX template:

    pandoc -D latex

Build a document using a custom LaTeX template:

    pandoc --template=template.latex

