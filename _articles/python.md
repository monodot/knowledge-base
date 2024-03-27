---
layout: page
title: Python
---

## Terminology

- **Module** - A module is a file containing Python definitions and statements. The file name is the module name with the suffix `.py` appended.
- **Packages**
  - An `__init__.py` file [is required][1] to make Python treat a directory containing this file as a package

## Project structures

From [the docs][1]:

```
sound/                          Top-level package
      __init__.py               Initialize the sound package
      formats/                  Subpackage for file format conversions
              __init__.py
              wavread.py
              wavwrite.py
              aiffread.py
              aiffwrite.py
              auread.py
              auwrite.py
              ...
      effects/                  Subpackage for sound effects
              __init__.py
              echo.py
              surround.py
              reverse.py
              ...
      filters/                  Subpackage for filters
              __init__.py
              equalizer.py
              vocoder.py
              karaoke.py
              ...
```

[1]: https://docs.python.org/3/tutorial/modules.html#packages
