ENV['RACK_ENV'] = 'test'


# SimpleCov must be loaded before the Sinatra DSL
# and the application code.
require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'sinatra'
require 'test/unit'
require 'rack/test'
require 'base64'
require 'json'
require 'timecop'
require './event'

class ApplicationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def make_an_event(event)
    post '/events', event.to_json
    assert_equal 200, last_response.status

    event = JSON.parse(last_response.body)
    refute_nil event['id']
    assert_equal Fixnum, event['id'].class
    assert_equal "/events/#{event['id']}", last_response.headers['Location']

    event['id'].to_s
  end

  def retrieve_event(event_id)
    get '/events/' + event_id
    assert_equal 200, last_response.status

    returned_event = JSON.parse(last_response.body)
    refute_nil returned_event
    
    returned_event
  end
  
  def test_add_event_no_name
    post '/events', {"name1" => "Don't forget"}.to_json
    assert_equal 400, last_response.status
  end
  
  
  def test_get_event_list
    get '/events'
    assert_equal 200, last_response.status
  end
  
  def test_add_and_retrieve_event

    event = {
        "name" => "event"
    }

    event_id = make_an_event(event)

    returned_event = retrieve_event(event_id)

    event.each_key do |k|
      refute_nil returned_event[k]
      assert_equal event[k], returned_event[k]
    end
  end

  def test_add_and_remove_event
    event = {
        "name" => "event 1"
    }

    event_id = make_an_event(event)
    delete '/events/' + event_id
    assert_equal 204, last_response.status

    get '/event_id/' + event_id
    assert_equal 404, last_response.status
  end

  def test_get_non_existent_event
    get '/events/gone' 
    assert_equal 404, last_response.status
  end

  def test_update_non_existent_event
    event = {
        "name" => "i dont exist"
    }

    put '/events/event_gone', event.to_json
    assert_equal 404, last_response.status
  end

  def test_delete_non_existent_event
    delete '/events/event_gone'
    assert_equal 404, last_response.status
  end
end
