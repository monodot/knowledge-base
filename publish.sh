#!/bin/bash -l
#
# Publishes this Jekyll static site to a directory
# Usage: ./publish.sh <env> <destPath>

#bundle config set path 'vendor/bundle'
#bundle install

echo "Building site..."
JEKYLL_ENV=${1:-production} bundle exec jekyll build -d ${2:-/var/www/kb.tomd.xyz/public_html}
echo "Site build complete."
