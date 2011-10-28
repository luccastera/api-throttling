require 'rubygems'
require 'rack/test'
require 'test/unit'
require 'context'
require File.expand_path(File.dirname(__FILE__) + '/../lib/api_throttling')

# this way we can include the module for any of the handler tests
module BasicTests
  def test_first_request_should_return_hello_world
    authorize "joe", "secret"
    get '/'
    assert_equal 200, last_response.status
    assert_equal "Hello World!", last_response.body
  end

  def test_fourth_request_should_be_blocked
    authorize "joe", "secret"
    3.times do
      get '/'
      assert_equal 200, last_response.status
    end
    get '/'
    assert_equal 503, last_response.status
  end

  def test_over_rate_limit_should_only_apply_to_user_that_went_over_the_limit
    authorize "joe", "secret"
    5.times { get '/' }
    assert_equal 503, last_response.status
    authorize "luc", "secret"
    get '/'
    assert_equal 200, last_response.status
  end

  def test_over_rate_limit_should_return_a_retry_after_header
    authorize "joe", "secret"
    4.times { get '/' }
    assert_equal 503, last_response.status
    assert_not_nil last_response.headers['Retry-After']
  end

  def test_retry_after_should_be_less_than_60_minutes
    authorize "joe", "secret"
    4.times { get '/' }
    assert_equal 503, last_response.status
    assert last_response.headers['Retry-After'].to_i <= (60 * 60)
  end

  def test_should_require_authorization
    get '/'
    assert_equal 401, last_response.status
  end

end
