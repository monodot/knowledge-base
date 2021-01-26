---
layout: page
title: Asciidoctor
---

## Code

Writing code in Asciidoctor, with callouts and syntax highlighting:

```
[source,java]
----
from("file:myfolder/input")
  .to("direct:process-file"); <1>

from("direct:process-file")
  .choice()
      .when(simple("${body} contains 'Cilla Black'"))
      .to("file:myfolder/cilla_black");
  .endChoice();
----
<1> a callout goes here
```

- Callouts require UTF-8 glyphs that most fonts do not have.
- So, rendering callouts in PDFs is dependent on the _M+ 1mn_ font. [GitHub][1]
- Or you can copy the relevant number glyphs into the font you want to use, using a tool like _fontforge_.
- The Unicode range for the glyphs is U+2460 - U+2473.
- If you don't provide the font that contains all the glyphs the content needs, you get a square box (or some other placeholder). [GitHub][2]

## Syntax examples

Image (block):

```
image::hello.jpg
```

Image (inline):

```
image:hello.jpg
```

Image (inline, with wrap):

```
image:hello.jpg[role=left]
```

Icons:

```
icon:fire[]
```

UI elements:

```
btn:[Save]
```

## Custom fonts

You must check font compatibility first, e.g. using this script (from asciidoctor-pdf Theming Guide):

```
require 'ttfunk'
require 'ttfunk/subset_collection'

ttf_subsets = TTFunk::SubsetCollection.new TTFunk::File.open ARGV[0]
(0...(ttf_subsets.instance_variable_get :@subsets).size).each {|idx| ttf_subsets[idx].encode }
```

## Colours/theming in PDF

Add this to the theme YAML:

```
role:
  red:
    font-color: #ff0000
```

Add this to the doc:

```
Error text is shown in [.red]#red#.
```

[1]: https://github.com/asciidoctor/asciidoctor-pdf/issues/377
[2]: https://github.com/asciidoctor/asciidoctor-pdf/issues/409
