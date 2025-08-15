# app/services/redis_cache/users.rb
# frozen_string_literal: true

require "json"
require "connection_pool"

module RedisCache
  class Users
    DEFAULT_TTL = ENV.fetch("USER_CACHE_TTL_SECONDS", 12.hours.to_i).to_i
    KEY_NS    = "users"
    INDEX_KEY = "#{KEY_NS}:ids"

    def initialize(pool: default_pool, ttl: DEFAULT_TTL)
      @pool = pool
      @ttl  = ttl.to_i.positive? ? ttl.to_i : nil
    end

    def cache_on_register(user)
      id      = user_id(user)
      key     = key_for(id)
      payload = serialize_user(user)

      @pool.with do |r|
        if @ttl
          r.set(key, payload, nx: true, ex: @ttl)
        else
          r.set(key, payload, nx: true)
        end
        r.sadd(INDEX_KEY, id)
        json_to_hash(r.get(key))
      end
    end

    def update(user)
      id      = user_id(user)
      key     = key_for(id)
      payload = serialize_user(user)

      @pool.with do |r|
        if @ttl
          r.set(key, payload, ex: @ttl)
        else
          r.set(key, payload)
        end
        r.sadd(INDEX_KEY, id)
        json_to_hash(payload)
      end
    end

    def delete(id_or_user)
      id  = user_id(id_or_user)
      key = key_for(id)

      @pool.with do |r|
        deleted = r.del(key)
        r.srem(INDEX_KEY, id)
        deleted
      end
    end

    def exists?(id_or_user)
      id  = user_id(id_or_user)
      key = key_for(id)
      @pool.with { |r| r.exists?(key) }
    end

    def fetch(id_or_user)
      id  = user_id(id_or_user)
      key = key_for(id)

      @pool.with do |r|
        raw = r.get(key)
        raw ? json_to_hash(raw) : nil
      end
    end

    def all_cached_ids
      @pool.with { |r| r.smembers(INDEX_KEY) }
    end

    private

    def default_pool
      @__default_pool ||= ConnectionPool.new(
        size: Integer(ENV.fetch("REDIS_POOL_SIZE", 5)), timeout: 5
      ) do
        # Note the leading :: to reference the gem’s Redis class
        ::Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"))
      end
    end

    def key_for(id) "#{KEY_NS}:#{id}" end
    def user_id(id_or_user) id_or_user.respond_to?(:id) ? id_or_user.id : id_or_user end

    def serialize_user(user)
      data = if user.respond_to?(:as_json)
               user.as_json(only: %i[id email name], methods: %i[updated_at])
             else
               user
             end
      JSON.generate(data)
    end

    def json_to_hash(str)
      JSON.parse(str)
    rescue JSON::ParserError
      nil
    end
  end
end
