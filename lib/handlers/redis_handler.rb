require 'redis'
module Handlers
  class RedisHandler < Handler
    cache_class "Redis"
    
    def increment(key)
      @cache.incr(key)
    end
    
    def get(key)
      @cache[key]
    end
  end
end