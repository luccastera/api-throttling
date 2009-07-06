require 'memcache'
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestApiThrottlingMemcache < Test::Unit::TestCase
  include Rack::Test::Methods
  include BasicTests
  CACHE = MemCache.new 'localhost:11211', :namespace=>'api-throttling-tests'

  def app
    app = Rack::Builder.new {
      use ApiThrottling, :requests_per_hour => 3, :cache => CACHE
      run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
    }
  end
  
  def setup
    CACHE.flush_all
  end
  
  def test_cache_handler_should_be_memcache
    assert_equal "Handlers::MemCacheHandler", app.to_app.instance_variable_get(:@handler).to_s
  end

end
