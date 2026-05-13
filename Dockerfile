FROM ruby:latest

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      git \
      libpq-dev \
      libsqlite3-dev \
      libvips \
      libyaml-dev \
      pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV BUNDLE_PATH=/app/vendor/bundle \
    BUNDLE_BIN=/app/vendor/bundle/bin \
    PATH=/app/vendor/bundle/bin:$PATH \
    LANG=C.UTF-8

EXPOSE 3000

CMD ["bash", "-lc", "bundle check >/dev/null 2>&1 || bundle install && bin/rails server -b 0.0.0.0 -p 3000"]
