FROM ruby:3.4.4

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		postgresql-client \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY Gemfile* ./
RUN bundle install

COPY . .
RUN chmod +x ./bin/docker-entrypoint

ENTRYPOINT ["./bin/docker-entrypoint"]
EXPOSE 3000
