#!/usr/bin/env
set -euo pipefail

wait_for() {
  host="$1"; port="$2"
  echo "⏳ waiting for $host:$port..."
  for i in {1..60}; do
    (echo > /dev/tcp/$host/$port) >/dev/null 2>&1 && echo "✅ $host:$port up" && return 0
    sleep 1
  done
  echo "❌ $host:$port not reachable" >&2
  exit 1
}

# Wait for DB & Redis
wait_for "${DATABASE_HOST:-db}" 5432
wait_for "$(echo "${REDIS_URL:-redis://redis:6379/1}" | sed -E 's|redis://([^:/]+).*|\1|')" \
         "$(echo "${REDIS_URL:-redis://redis:6379/1}" | sed -E 's|redis://[^:]+:([0-9]+).*|\1|')"

# DB setup
bundle exec rails db:prepare

# Start Sidekiq
exec bundle exec sidekiq