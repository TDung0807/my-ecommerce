FROM ruby:3.3-slim

# --- Env ---
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/usr/local/bundle \
    # compile native gems on arm64 if needed
    BUNDLE_FORCE_RUBY_PLATFORM=true

# --- System deps for pg/nokogiri/etc. + psql client ---
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      postgresql-client \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# --- Install gems ---
COPY Gemfile Gemfile.lock ./
# Add arm64 platform to the lockfile during image build (best is to commit this change in repo)
RUN bundle lock --add-platform aarch64-linux \
 && bundle install

# --- App code ---
COPY . .

# --- Entrypoints (fix CRLF if any) ---
COPY docker/entrypoint.web.sh /usr/bin/entrypoint.web.sh
COPY docker/entrypoint.sidekiq.sh /usr/bin/entrypoint.sidekiq.sh
RUN sed -i 's/\r$//' /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh \
 && chmod +x /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh

EXPOSE 3000
ENTRYPOINT ["/usr/bin/entrypoint.web.sh"]
