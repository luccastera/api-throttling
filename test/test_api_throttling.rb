require 'redis'
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

#  To Run this test, you need to have the redis-server running.
#  And you need to have rack-test gem installed: sudo gem install rack-test
#  For more information on rack-test, visit: http://github.com/brynary/rack-test

class ApiThrottlingTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  context "using redis" do
    before do
      # Delete all the keys for 'joe' in Redis so that every test starts fresh
      # Having this here also helps as a reminder to start redis-server
      begin
  		  r = Redis.new
  		  r.keys("*").each do |key|
  		    r.delete key
  		  end
  		  
      rescue Errno::ECONNREFUSED
        assert false, "You need to start redis-server"
      end
    end
    
    context "with authentication required" do
      include BasicTests
      
      def app
        app = Rack::Builder.new {
          use ApiThrottling, :requests_per_hour => 3
          run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
        }
      end
    
      def test_cache_handler_should_be_redis
        assert_equal "Handlers::RedisHandler", app.to_app.instance_variable_get(:@handler).to_s
      end
      
    end
    
    context "without authentication required" do
      def app
        app = Rack::Builder.new {
          use ApiThrottling, :requests_per_hour => 3, :auth=>false
          run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
        }
      end

      def test_should_not_require_authorization
        3.times do
          get '/'
          assert_equal 200, last_response.status
        end
        get '/'
        assert_equal 503, last_response.status
      end
    end
    
    context "with rate limit key based on url" do
      def app
        app = Rack::Builder.new {
          use ApiThrottling, :requests_per_hour => 3, 
                             :key=>Proc.new{ |env,auth| "#{auth.username}_#{env['PATH_INFO']}_#{Time.now.strftime("%Y-%m-%d-%H")}" }
          run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
        }
      end
      
      test "should throttle requests based on the user and url called" do
        authorize "joe", "secret"
        3.times do
          get '/'
          assert_equal 200, last_response.status
        end
        get '/'
        assert_equal 503, last_response.status
        
        3.times do
          get '/awesome'
          assert_equal 200, last_response.status
        end
        get '/awesome'
        assert_equal 503, last_response.status
        
        authorize "luc", "secret"
        get '/awesome'
        assert_equal 200, last_response.status
        
        get '/'
        assert_equal 200, last_response.status
      end
    end
  end
  
  context "using active support cache store" do
    require 'active_support'
    
    context "memory store" do
      include BasicTests

      before do
        @@cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
      end
      
      def app
        app = Rack::Builder.new {
          use ApiThrottling, :requests_per_hour => 3, :cache=>@@cache_store
          run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
        }
      end
      
      def test_cache_handler_should_be_memcache
        assert_equal "Handlers::ActiveSupportCacheStoreHandler", app.to_app.instance_variable_get(:@handler).to_s
      end
    end
    
    context "memcache store" do
      include BasicTests
      
      
      before do
        @@cache_store = ActiveSupport::Cache.lookup_store(:memCache_store)
        @@cache_store.clear
      end
      
      def app
        app = Rack::Builder.new {
          use ApiThrottling, :requests_per_hour => 3, :cache=>@@cache_store
          run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
        }
      end
      
      def test_cache_handler_should_be_memcache
        assert_equal "Handlers::ActiveSupportCacheStoreHandler", app.to_app.instance_variable_get(:@handler).to_s
      end
    end
  end
  
end
