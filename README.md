# Bandcamp API ![](https://travis-ci.org/hcxp/bandcamp-api.svg?branch=master)

As of today, [Bandcamp](https://bandcamp.com) does not provides an API for
retrieving info about bands and their music in a developer friendly way. Aim of
this project is to provide a self-hosted service that crawls given bands
profiles and exposes found data using json:api format.

## Setup

How to prepare (create and migrate) DB for `development` and `test` environments:

```
% bundle exec hanami db prepare

% HANAMI_ENV=test bundle exec hanami db prepare
```

How to run the development server:

```
% gem install foreman
% foreman start -f Procfile.dev
```

How to run the development console:

```
% bundle exec hanami console
```

How to run tests:

```
% bundle exec rspec
```
