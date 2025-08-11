# syntax=docker/dockerfile:1.7
FROM ruby:3.3-slim AS base
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_FORCE_RUBY_PLATFORM=true
WORKDIR /app

# ---------- builder ----------
FROM base AS builder
# build deps only (for native gems)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      libyaml-dev \
      pkg-config \
 && rm -rf /var/lib/apt/lists/*

# Install gems with cached mounts (reused across builds and arches via buildx cache-to/from)
COPY Gemfile Gemfile.lock ./
RUN --mount=type=cache,target=/usr/local/bundle \
    --mount=type=cache,target=/root/.bundle \
    bundle install --verbose

# app files last for better caching
COPY . .

# ---------- runtime ----------
FROM base AS runtime
# only runtime libs (no compilers)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libpq5 \
      libyaml-0-2 \
      postgresql-client \
 && rm -rf /var/lib/apt/lists/*

# bring gems from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# entrypoints
COPY docker/entrypoint.web.sh /usr/bin/entrypoint.web.sh
COPY docker/entrypoint.sidekiq.sh /usr/bin/entrypoint.sidekiq.sh
RUN sed -i 's/\r$//' /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh \
 && chmod +x /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh

EXPOSE 3000
ENTRYPOINT ["/usr/bin/entrypoint.web.sh"]
