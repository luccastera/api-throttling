require 'api_throttling'

use Rack::Lint
use Rack::ShowExceptions
use ApiThrottling, :requests_per_hour => 3

run lambda {|env| [200, {'Content-Type' =>  'text/plain', 'Content-Length' => '12'}, ["Hello World!"] ] }
