# knowledge-base

A static site of knowledge, tips and tricks that I've learned over the years, and wanted to gather together in a central place.

You don't need to build this repo. You can just browse the site here: <https://kb.tomd.xyz>

## A small disclaimer

**These are my unsanitised, community notes from my own learning. They are shared here for your benefit, for you to read.**

**No content from these pages should be taken as "best practices", advice, or scripts suitable for running production-level services. Please take time to understand what these scripts are doing to your system(s) before you execute them.**

**And of course, no warranty provided or liability assumed.**

## Building the site

To install and run:

    $ bundle config set path 'vendor/bundle'
    $ bundle install
    $ bundle exec jekyll serve

## Writing

How to write things in this static site.

Internal links look like this:

```
[maven]: {{ site.baseurl }}{% link _articles/maven.md %}
```

## Contributing

Pull requests are welcome! If you see anything that needs improvement, please feel free to submit a PR.

## Licence

Code licensed under GNU GPL v3. Content is (c) Tom and contributors.
