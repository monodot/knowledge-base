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

## Build and deployment

### Example Dockerfile 

An example Dockerfile that builds a Jekyll website and serves it using nginx:

```dockerfile
FROM docker.io/jekyll/jekyll:4.2.2 AS jekyll

WORKDIR /app

# You can comment these out if the source site doesn't use any npm modules
COPY package.json package-lock.json .
RUN npm install

# Copy the Gemfile and install dependencies separately, so we can cache them
COPY Gemfile Gemfile.lock .
RUN bundle install

# Copy all of the source files. We run the jekyll command directly, rather than
# to avoid a conflict with the bundler-installed jekyll.
COPY . .
ENV JEKYLL_ENV=production
RUN jekyll build

# ---

FROM docker.io/library/nginx:1.23-alpine

COPY --from=jekyll /app/_site /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
# CMD ["nginx", "-g", "daemon off;"]
``````

## Cookbook

### Check if production build

Check whether the site is production (useful for rendering certain content only on the live site, e.g. Disqus comments, Google Analytics, etc.):

    # assuming that JEKYLL_ENV=production is set when publishing
    {% if jekyll.environment == "production" %}
    ...
    {% endif %}

### Fetch data from a Google Sheet

To make it easier to create slightly more _dynamic_ sites, you can store site data in a Google Sheet. Then, use Jekyll's plugin APIs to download the sheet as CSV into the `_data` directory, before the site initialisation takes place. e.g.:

```ruby
# _plugins/jekyll-download-csv.rb

require 'open-uri'

# Downloads the CSV file that contains the product catalogue
Jekyll::Hooks.register :site, :after_init do |_site|
  url = 'https://docs.google.com/spreadsheets/d/<your-spreadsheet-identifier>/export?exportFormat=csv'
  filename = '_data/products.csv' # Specify the desired name for the downloaded file

  URI.open(url) do |remote_file|
    File.open(filename, 'wb') do |local_file|
      local_file.write(remote_file.read)
    end
  end
end
```

Then the data in the CSV will be available as `site.data.products`.


### Upgrading

1.  Update the `Gemfile` with the versions to target.
2.  Run `bundle update <gem> [<gem> <gem> ...]`
