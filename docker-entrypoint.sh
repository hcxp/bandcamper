#!/bin/sh

bundle exec hanami db prepare

exec "$@"
