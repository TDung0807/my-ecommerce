#!/bin/bash
set -e

# Remove any stale server PID
rm -f tmp/pids/server.pid

# Run database migrations (optional, remove if not needed for dev)
bundle exec rails db:migrate 2>/dev/null || true

# Start Rails server on 0.0.0.0
exec bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}