module Handlers
  class HashHandler < Handler
    cache_class "Hash"
    
    def increment(key)
      @cache[key] = (get(key)||0).to_i+1
    end
    
    def get(key)
      @cache[key]
    end
  end
end