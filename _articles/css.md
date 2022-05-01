---
layout: page
title: CSS
---

## Cookbook

### A modal form that appears when a button is clicked

When a link is clicked, a modal window will be shown. (Useful for pop-up forms, etc.)

```
.modal { display: none; }
.modal {
    position: fixed;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    z-index: -1;
    display: flex;
    transition: opacity 100ms;
    opacity: 0;
    align-items: center;
    justify-content: center;
}
.modal:target {
    visibility: visible;
    opacity: 1;
    z-index: 100;
}
.modal div.content {
    position: relative;
    padding: 1.5rem;
    margin: 0.5rem;
    background-color: white;
    /* z-index: 2; */
}
.modal .close {
    position: relative;
    display: block;
}
.modal .close::after {
    right: 1rem;
    top: 1rem;
    width: 2rem;
    height: 2rem;
    position: absolute;
    display: flex;
    z-index: 1;
    align-items: center;
    justify-content: center;
    color: black;
    content: "×";
    font-size: 2rem;
    cursor: pointer;
}
.modal .close::before {
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    /* z-index: 1; */
    position: fixed;
    background-color: rgba(0,0,0,.7);
    content: "";
    cursor: default;
}
.modal h3 {
    text-align: center;
    margin-top: 0.5rem;
    font-size: 1.125rem;
    line-height: 1.5rem;
}
@media(min-width: 750px) {
    .modal div.content {
        width: 550px;
    }
    .modal button[type=submit] { font-size: 1.25rem; }
    .modal h3 { font-size: 1.5rem; line-height: 1.75rem; }
}
```

And the HTML:

```
<p><a href="#download-modal"><b>Open the form</b></a></p>

<div class="modal" id="download-modal">
    <div>
        <a href="#close" class="close" rel="parent"></a>
        <div class="content">
            <h3>
              Some form heading here
            </h3>
            <form class="newsletter" action="https://example.com" method="POST" accept-charset="utf-8">
                <label for="email">Your email</label><br/>
                <input type="email" name="email" id="email"/><br/>
                <button type="submit" name="btnSubmit" id="btnSubmit">Submit this</button>
            </form>
        </div>
    </div>
</div>
```

### Allow code blocks in `pre` tags to wrap correctly

Use `min-width`:

```
section.post > article {
    flex: 1 1 auto; // allow a flex item to grow and shrink, taking into account its initial size / ratio compared to other flex items
    min-width: 0; // This allows code blocks (in <pre> tags) to wrap correctly - https://weblog.west-wind.com/posts/2016/feb/15/flexbox-containers-pre-tags-and-managing-overflow
}
```

### Make an auto-hiding nav menu

```
body > header > div.silos > nav > ul {
    list-style-type: none;
    margin: 0;
    padding: 0;
    /* Clever stuff to make menu hide */
    max-height: 0;
    overflow: hidden;
}
body > header > div.silos > input[type=checkbox]:checked ~ nav {
    padding: 1rem 0;
}
body > header > div.silos > input[type=checkbox]:checked ~ nav ul {
    // Select the 'nav ul' element adjacent to the toggling checkbox
    max-height: 350px;
}
body > header > div.silos > nav > ul > li > a {
    display: inline-block;
    box-sizing: border-box;
    width: 100%;
    margin: 0;
    padding: 0.5rem var(--gutter);
    color: var(--body-text-colour);
    font-size: 1.25rem;
    text-decoration: none;
}
body > header > div.silos > nav > ul > li > a:hover {
    background-color: var(--header-background-colour);
}
body > header > div.primary > div.actions,
body > header > div.primary > div.strapline {
    display: none; // Hide on smaller displays
}
```
