#!/bin/bash -l
#
# Publishes this Jekyll static site
# Usage: ./publish.sh <env> <bundleCacheLocation>

JEKYLL_ENV=${1:-production}
BUNDLE_APP_CONFIG=${2:-/usr/local/bundle}

echo "Building site..."

# Run the bundle install and jekyll build in a container
# The ruby container uses /usr/local/bundle as a local artifact location
podman run --rm \
    -v "$PWD":/usr/src/site \
    -v ${BUNDLE_APP_CONFIG}:/usr/local/bundle \
    -w /usr/src/site \
    -e JEKYLL_ENV=${JEKYLL_ENV} \
    docker.io/library/ruby:2.7 /bin/bash -c "bundle install && bundle exec jekyll build"

echo "Site build complete."
