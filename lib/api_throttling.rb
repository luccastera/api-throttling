require 'rubygems'
require 'rack'
require File.expand_path(File.dirname(__FILE__) + '/handlers/handlers')

class ApiThrottling
  def initialize(app, options={})
    @app = app
    @options = {:requests_per_hour => 60, :cache=>:redis, :auth=>true}.merge(options)
    @handler = Handlers.cache_handler_for(@options[:cache])
    raise "Sorry, we couldn't find a handler for the cache you specified: #{@options[:cache]}" unless @handler
  end

  def call(env, options={})
    if @options[:auth]
      auth = Rack::Auth::Basic::Request.new(env)
      return auth_required unless auth.provided?
      return bad_request unless auth.basic?
    end

    begin
	    cache = @handler.new(@options[:cache])
	    key = generate_key(env, auth)
	    cache.increment(key)
	    return over_rate_limit if cache.get(key).to_i > @options[:requests_per_hour]
	  rescue Errno::ECONNREFUSED
	    # If Redis-server is not running, instead of throwing an error, we simply do not throttle the API
	    # It's better if your service is up and running but not throttling API, then to have it throw errors for all users
	    # Make sure you monitor your redis-server so that it's never down. monit is a great tool for that.
	  end
    @app.call(env)
  end

  def generate_key(env, auth)
    return @options[:key].call(env, auth) if @options[:key]
    auth ? "#{auth.username}_#{Time.now.strftime("%Y-%m-%d-%H")}" : "#{Time.now.strftime("%Y-%m-%d-%H")}"
  end

  def bad_request
    body_text = "Bad Request"
    [ 400, { 'Content-Type' => 'text/plain', 'Content-Length' => body_text.size.to_s }, [body_text] ]
  end

  def auth_required
    body_text = "Authorization Required"
    [ 401, { 'Content-Type' => 'text/plain', 'Content-Length' => body_text.size.to_s }, [body_text] ]
  end

  def over_rate_limit
    body_text = "Over Rate Limit"
    retry_after_in_seconds = (60 - Time.now.min) * 60
    [ 503,
      { 'Content-Type' => 'text/plain',
        'Content-Length' => body_text.size.to_s,
        'Retry-After' => retry_after_in_seconds.to_s
      },
      [body_text]
    ]
  end
end


