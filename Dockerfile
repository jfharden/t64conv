ARG RUBY_VERSION=2.7
FROM ruby:${RUBY_VERSION}-buster

RUN echo "deb http://deb.debian.org/debian buster contrib" >> /etc/apt/sources.list \
  && apt-get update && apt-get install -y \
    vice \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /t64conv/output /t64conv/source /t64conv/gem/

COPY ./t64conv-*.gem /t64conv/gem

WORKDIR /t64conv

RUN gem install /t64conv/gem/t64conv-*.gem
