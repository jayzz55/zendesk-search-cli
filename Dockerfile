FROM ruby:3.0.1-alpine3.13 AS base

RUN apk --update add -t build-deps \
  build-base

RUN apk --update add \
  bash \
  coreutils \
  git

WORKDIR /app

# Dev image
FROM base as dev

FROM dev as build

COPY Gemfile* *.gemspec ./

RUN bundle install

COPY . .

CMD ["./bin/run"]
