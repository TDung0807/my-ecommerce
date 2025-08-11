FROM ruby:3.3-slim

ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_FORCE_RUBY_PLATFORM=true

# + libyaml-dev + pkg-config for psych
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      postgresql-client \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Ensure arm64 is allowed (best: commit this change)
COPY Gemfile Gemfile.lock ./
RUN bundle lock --add-platform aarch64-linux && bundle install

COPY . .

COPY docker/entrypoint.web.sh /usr/bin/entrypoint.web.sh
COPY docker/entrypoint.sidekiq.sh /usr/bin/entrypoint.sidekiq.sh
RUN sed -i 's/\r$//' /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh \
 && chmod +x /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh

EXPOSE 3000
ENTRYPOINT ["/usr/bin/entrypoint.web.sh"]
