---
layout: page
title: HTML
---


## Performance optimisations

### Lazy-loading images

To [lazy load images](https://developer.mozilla.org/en-US/docs/Web/Performance/Lazy_loading), use `loading="lazy"`.

Full example:

    <figure style="max-width: 600px" class="...">
        <div class="backlinko-img-placeholder" style="display: none; padding-bottom: 95.583333333333%"></div>
        <img title="..." alt="..." src="" sizes="(max-width: 600px) 100vw, 600px" style="max-width: 1000px !important" loading="lazy" decoding="async">
    </figure>

