FROM ruby:2.5.0-alpine

RUN apk add --update \
  curl \
  build-base \
  tzdata \
  postgresql-dev \
  sqlite sqlite-dev sqlite-libs \
  bash \
  git \
  && rm -rf /var/cache/apk/*

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem install foreman
RUN bundle install --jobs 20 --retry 5 --without development test --path vendor/bundle

ENV HANAMI_HOST=0.0.0.0
ENV HANAMI_ENV=production

COPY . /app

EXPOSE 2300

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD foreman start -f Procfile.dev
