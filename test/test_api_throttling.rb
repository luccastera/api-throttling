require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require 'redis'

#  To Run this test, you need to have the redis-server running.
#  And you need to have rack-test gem installed: sudo gem install rack-test
#  For more information on rack-test, visit: http://github.com/brynary/rack-test

class ApiThrottlingTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include BasicTests

  def app
    app = Rack::Builder.new {
      use ApiThrottling, :requests_per_hour => 3
      run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
    }
  end
  
  def setup
    # Delete all the keys for 'joe' in Redis so that every test starts fresh
    # Having this here also helps as a reminder to start redis-server
    begin
		  r = Redis.new
		  r.keys("joe*").each do |key|
		    r.delete key
		  end
		  r.keys("luc*").each do |key|
		    r.delete key
		  end
    rescue Errno::ECONNREFUSED
      assert false, "You need to start redis-server"
    end
  end
  
  def test_cache_handler_should_be_redis
    assert_equal "Handlers::RedisHandler", app.to_app.instance_variable_get(:@handler).to_s
  end
  
end
