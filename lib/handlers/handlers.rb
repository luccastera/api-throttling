module Handlers
  HANDLERS = {}
    
  def self.cache_handler_for(info)
    HANDLERS[info.to_s.downcase] || HANDLERS[info.class.to_s.downcase]
  end
  
  def self.add_handler(handler, key=nil)
    HANDLERS[key || handler.cache_class.downcase] = handler
  end
  
  # creating a new cache handler is as simple as extending from the handler class,
  # setting the class to use as the cache by calling cache_class("Redis")
  # and then implementing the increment and get methods for that cache type.
  #
  # If you don't want to extend from Handler you can just create a class that implements
  # increment(key), get(key) and handles?(info)
  # 
  # you can then initialize the middleware and pass :cache=>CACHE_NAME as an option.
  class Handler
    def initialize(object=nil)
      cache = Object.const_get(self.class.cache_class)
      @cache = object.is_a?(cache) ? object : cache.new
    end
    
    def increment(key)
      raise "Cache Handlers must implement an increment method"
    end
    
    def get(key)
      raise "Cache Handlers must implement a get method"
    end
    
    class << self    
  
      def cache_class(name = nil)
        @cache_class = name if name
        @cache_class
      end
    end
  end

  %w(redis_handler memcache_handler hash_handler active_support_cache_store_handler).each do |handler|
    require File.expand_path(File.dirname(__FILE__) + "/#{handler}")
  end  
end