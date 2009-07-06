require 'redis'
require 'memcache'
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class HandlersTest < Test::Unit::TestCase

  should "select redis handler" do
    [:redis, 'redis', 'Redis', Redis.new].each do |key|
      assert_equal Handlers::RedisHandler, Handlers.cache_handler_for(key)
    end
  end

  should "select memcache handler" do
    [:memcache, 'memcache', 'MemCache', MemCache.new].each do |key|
      assert_equal Handlers::MemCacheHandler, Handlers.cache_handler_for(key)
    end
  end
  
  should "select hash handler" do
    [:hash, 'hash', 'Hash', {}].each do |key|
      assert_equal Handlers::HashHandler, Handlers.cache_handler_for(key)
    end
  end
  
end
