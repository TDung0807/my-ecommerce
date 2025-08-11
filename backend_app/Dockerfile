# syntax=docker/dockerfile:1.7

FROM ruby:3.3-slim AS base
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_FORCE_RUBY_PLATFORM=true
WORKDIR /app

# ---------- builder ----------
FROM base AS builder
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      libyaml-dev \
      pkg-config \
      git \
      ca-certificates \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Don’t use BUNDLE_DEPLOYMENT=1 during build; install from lockfile
COPY Gemfile Gemfile.lock ./
RUN --mount=type=cache,target=/usr/local/bundle \
    --mount=type=cache,target=/root/.bundle \
    bundle install --verbose

COPY . .

# ---------- runtime ----------
FROM base AS runtime
# runtime libs only
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libpq5 \
      libyaml-0-2 \
      postgresql-client \
      ca-certificates \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Move gems and app
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# entrypoints (as you had)
COPY docker/entrypoint.web.sh /usr/bin/entrypoint.web.sh
COPY docker/entrypoint.sidekiq.sh /usr/bin/entrypoint.sidekiq.sh
RUN sed -i 's/\r$//' /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh \
 && chmod +x /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh

EXPOSE 3000
ENTRYPOINT ["/usr/bin/entrypoint.web.sh"]
