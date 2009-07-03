require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require 'redis'
require 'memcache'

class HandlersTest < Test::Unit::TestCase
  
  def setup
    
  end
  
  def test_redis_should_handle_redis
    assert Handlers::RedisHandler.handles?(:redis)
    assert Handlers::RedisHandler.handles?('redis')
    assert Handlers::RedisHandler.handles?('Redis')
    assert Handlers::RedisHandler.handles?(Redis.new)
  end
  
  def test_redis_should_not_handle_memcache
    assert !Handlers::RedisHandler.handles?(:memcache)
    assert !Handlers::RedisHandler.handles?('memcache')
    assert !Handlers::RedisHandler.handles?('MemCache')
    assert !Handlers::RedisHandler.handles?(MemCache.new)
  end
  
  def test_memcache_should_not_handle_redis
    assert !Handlers::MemCacheHandler.handles?(:redis)
    assert !Handlers::MemCacheHandler.handles?('redis')
    assert !Handlers::MemCacheHandler.handles?('Redis')
    assert !Handlers::MemCacheHandler.handles?(Redis.new)
  end
  
  def test_memcache_should_handle_memcache
    assert Handlers::MemCacheHandler.handles?(:memcache)
    assert Handlers::MemCacheHandler.handles?('memcache')
    assert Handlers::MemCacheHandler.handles?('MemCache')
    assert Handlers::MemCacheHandler.handles?(MemCache.new)
  end
  
end
