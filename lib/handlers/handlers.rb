module Handlers
  # creating a new cache handler is as simple as extending from the handler class,
  # setting the class to use as the cache by calling cache_class("Redis")
  # and then implementing the increment and get methods for that cache type.
  #
  # If you don't want to extend from Handler you can just create a class that implements
  # increment(key), get(key) and handles?(info)
  # 
  # Once you have a new handler make sure it is required in here and added to the Handlers list,
  # you can then initialize the middleware and pass :cache=>CACHE_NAME as an option.
  class Handler
    def initialize(object=nil)
      @cache = object.is_a?(self.class.cache_class) ? object : self.class.cache_class.new
    end
    
    def increment(key)
      raise "Cache Handlers must implement an increment method"
    end
    
    def get(key)
      raise "Cache Handlers must implement a get method"
    end
    
    class << self    
      def handles?(info)
        info.to_s.downcase == cache_class.to_s.downcase || info.is_a?(self.cache_class)
      end
    
      def cache_class(name = nil)
        @cache_class = name if name
        Object.const_get(@cache_class) if @cache_class
      end
    end
  end
  
  %w(redis_handler memcache_handler).each do |handler|
    require File.expand_path(File.dirname(__FILE__) + "/#{handler}")
  end
  
  HANDLERS = [RedisHandler, MemCacheHandler]
  
  def self.cache_handler_for(info)
    HANDLERS.detect{|handler| handler.handles?(info)}
  end
  
end