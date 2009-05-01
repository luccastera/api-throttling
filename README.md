# Rack Middleware for Api Throttling

<p>I will show you a technique to impose a rate limit (aka API Throttling) on a Ruby Web Service. I will be using Rack middleware so you can use this no matter what Ruby Web Framework you are using, as long as it is Rack-compliant.</p>

<h2>Introduction to Rack</h2>

<p>There are plenty of <a href="http://jasonseifer.com/2009/04/08/32-rack-resources-to-get-you-started">great resources</a> to learn the basic of Rack so I will not be explaining how Rack works here but you will need to understand it in order to follow this post. I highly recommend watching the <a href="http://remi.org/2009/02/19/rack-basics.html">three</a> <a href="http://remi.org/2009/02/24/rack-part-2.html">Rack</a> <a href="http://remi.org/2009/02/28/rack-part-3-middleware.html">screencasts</a> from <a href="http://remi.org/">Remi</a> to get started with Rack.</p>

## Basic Rack Application

<p>First, make sure you have the <a href="http://code.macournoyer.com/thin/">thin webserver</a> installed.</p>

<pre>sudo gem install thin</pre>

<p>We are going to use the following 'Hello World' Rack application to test our API Throttling middleware.</p> 

<pre>
require 'api_throttling'

use Rack::ShowExceptions
use Rack::Lint
use ApiThrottling, :requests_per_hour => 5

run lambda {|env| [200, {}, ["Hello World!"] ] }
</pre>


<p>Save this code in a file called <em>config.ru</em> and then you can run it with the thin webserver, using the following command:</p>

<pre>thin --rackup config.ru start</pre>

<p>Now you can open another terminal window (or a browser) to test that this is working as expected:</p>

<pre>curl -i http://localhost:3000</pre>

<p>The -i option tells curl to include the HTTP-header in the output so you should see the following:</p>

<pre>
$ curl -i http://localhost:3000
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 12
Connection: keep-alive
Server: thin 1.0.0 codename That's What She Said

Hello World!
</pre>

<p>At this point, we have a basic rack application that we can use to test our rack middleware. Now let's get started.</p>


<h2>Redis</h2>

<p>We need a way to memorize the number of requests that users are making to our web service if we want to limit the rate at which they can use the API. Every time they make a request, we want to check if they've gone past their rate limit before we respond to the request. We also want to store the fact that they've just made a request. Since every call to our web service requires this check and memorization process, we would like this to be done as fast as possible.</p>

<p>This is where Redis comes in. Redis is a super-fast key-value database that we've highlighted <a href="http://blog.messagepub.com/2009/04/20/project-spotlight-redis-a-fast-data-structure-database/">in a previous blog post</a>. It can do about 110,000 SETs per second, about 81,000 GETs per second. That's the kind of performance that we are looking for since we would not like our 'rate limiting' middleware to reduce the performance of our web service.</p>


<h2>Our Rack Middleware</h2>

<p>We are assuming that the web service is using HTTP Basic Authentication. You could use another type of authentication and adapt the code to fit your model.</p>

<p>Our rack middleware will do the following:</p>
<ul>
  <li>For every request received, increment a key in our database. The key string will consists of the authenticated username followed by a timestamp for the current hour. For example, for a user called joe, the key would be: <em><strong>joe_2009-05-01-12</em></strong></li>
  <li>If the value of that key is less than our 'maximum requests per hour limit', then return an HTTP Response with a status code of 503, indicating that the user has gone over his rate limit.</li>
  <li>If the value of the key is less than the maximum requests per hour limit, then allow the user's request to go through.</li>
</ul>

<p>Redis has an atomic <a href="http://code.google.com/p/redis/wiki/IncrCommand">INCR command</a> that is the perfect fit for our use case. It increments the key value by one. If the key does not exist, it sets the key to the value of "0" and then increments it. Awesome! We don't even need to write our own logic to check if the key exists before incrementing it, Redis takes care of that for us.</p>

<pre>
r = Redis.new
key = "#{auth.username}_#{Time.now.strftime("%Y-%m-%d-%H")}"
r.incr(key)
return over_rate_limit if r[key].to_i > @options[:requests_per_hour]
</pre>

<p>If our redis-server is not running, rather than throwing an error affecting all our users, we will let all the requests pass through by catching the exception and doing nothing. That means that if your redis-server goes down, you are no longer throttling the use of your web service so you need to make sure it's always running (using <a href="http://mmonit.com/monit/">monit</a> or <a href="http://god.rubyforge.org/">god</a>, for example).</p>

<p>Finally, we want anyone who might use this Rack middleware to be able to set their limit via the <em>requests_per_hour</em> option.</p>

<p>The full code for our middleware is below. You can also find it at <a href="https://github.com/dambalah/api-throttling">github.com/dambalah/api-throttling</a>.</p>

<pre>
require 'rubygems'
require 'rack'
require 'redis'

class ApiThrottling
  def initialize(app, options={})
    @app = app
    @options = {:requests_per_hour => 60}.merge(options)
  end
  
  def call(env, options={})
    auth = Rack::Auth::Basic::Request.new(env)
    if auth.provided?
      return bad_request unless auth.basic?
		  begin
		    r = Redis.new
		    key = "#{auth.username}_#{Time.now.strftime("%Y-%m-%d-%H")}"
		    r.incr(key)
		    return over_rate_limit if r[key].to_i > @options[:requests_per_hour]
		  rescue Errno::ECONNREFUSED
		    # If Redis-server is not running, instead of throwing an error, we simply do not throttle the API
		    # It's better if your service is up and running but not throttling API, then to have it throw errors for all users
		    # Make sure you monitor your redis-server so that it's never down. monit is a great tool for that.
		  end
    end
    @app.call(env)
  end
  
  def bad_request
    body_text = "Bad Request"
    [ 400, { 'Content-Type' => 'text/plain', 'Content-Length' => body_text.size.to_s }, [body_text] ]
  end
  
  def over_rate_limit
    body_text = "Over Rate Limit"
    [ 503, { 'Content-Type' => 'text/plain', 'Content-Length' => body_text.size.to_s }, [body_text] ]
  end
end
</pre>

<p>To use it on our 'Hello World' rack application, simply add it with the <em>use</em> keyword and the <em>:requests_per_hour</em> option:</p>

<pre>
require 'api_throttling'

use Rack::Lint
use Rack::ShowExceptions
use ApiThrottling, :requests_per_hour => 3

run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
</pre>

<p><strong>That's it!</strong> Make sure your <em>redis-server</em> is running on port 6379 and try making calls to your api with curl. The first 3 calls will be succesful but the next ones will block because you've reached the limit that we've set:</p>

<pre>
$ curl -i http://joe@localhost:3000
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 12
Connection: keep-alive
Server: thin 1.0.0 codename That's What She Said

Hello World!

$ curl -i http://joe@localhost:3000
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 12
Connection: keep-alive
Server: thin 1.0.0 codename That's What She Said

Hello World!

$ curl -i http://joe@localhost:3000
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 12
Connection: keep-alive
Server: thin 1.0.0 codename That's What She Said

Hello World!

$ curl -i http://joe@localhost:3000
HTTP/1.1 503 Service Unavailable
Content-Type: text/plain
Content-Length: 15
Connection: keep-alive
Server: thin 1.0.0 codename That's What She Said

Over Rate Limit
</pre>
