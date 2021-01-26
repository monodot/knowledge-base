---
layout: page
title: Jekyll
---

## Setup on Fedora

Setting up Jekyll on Fedora (needs C compilation tools):

    $ sudo dnf install ruby-devel redhat-rpm-config rubygem-bundler @development-tools @c-development
    $ gem install jekyll

Then, to build a site:

    $ cd path/to/your/site
    $ bundle install --path vendor/bundle
    $ bundle exec jekyll serve

## Cookbook

Check whether the site is production (useful for rendering certain content only on the live site, e.g. Disqus comments, Google Analytics, etc.):

    # assuming that JEKYLL_ENV=production is set when publishing
    {% if jekyll.environment == "production" %}
    ...
    {% endif %}

### Upgrading

1.  Update the `Gemfile` with the versions to target.
2.  Run `bundle update <gem> [<gem> <gem> ...]`
