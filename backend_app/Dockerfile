FROM ruby:3.4.4

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		postgresql-client \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .

COPY docker/entrypoint.web.sh /usr/bin/entrypoint.web.sh
COPY docker/entrypoint.sidekiq.sh /usr/bin/entrypoint.sidekiq.sh
RUN chmod +x /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh

ENTRYPOINT ["/usr/bin/entrypoint.web.sh"]
