module Handlers
  class MemCacheHandler < Handler
    cache_class "MemCache"
    
    def increment(key)
      @cache.set(key, (get(key)||0).to_i+1)
    end
    
    def get(key)
      @cache.get(key)
    end
    
    Handlers.add_handler self
  end
end