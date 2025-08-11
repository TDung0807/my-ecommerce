FROM ruby:3.4.4

ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_DEPLOYMENT=1

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		postgresql-client \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . .

COPY docker/entrypoint.web.sh /usr/bin/entrypoint.web.sh
COPY docker/entrypoint.sidekiq.sh /usr/bin/entrypoint.sidekiq.sh
RUN sed -i 's/\r$//' /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh \
 && chmod +x /usr/bin/entrypoint.web.sh /usr/bin/entrypoint.sidekiq.sh


EXPOSE 3000

ENTRYPOINT ["/usr/bin/entrypoint.web.sh"]

