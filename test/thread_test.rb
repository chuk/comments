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
require './app/thread'

class ApplicationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def create_a_new_thread(thread)
    post '/threads',thread.to_json
    assert_equal 200, last_response.status

    thread = JSON.parse(last_response.body)
    refute_nil thread['id']
    assert_equal String, thread['id'].class
    assert_equal 24, thread['id'].length
    assert_equal "/threads/#{thread['id']}", last_response.headers['Location']

    thread['id'].to_s
  end

  def retrieve_thread(thread_id)
    #puts "DEBUG: Getting thread_id: " + thread_id
    
    get '/threads/' + thread_id

    assert_equal 200, last_response.status

    returned_thread = JSON.parse(last_response.body)
    refute_nil returned_thread
    
    returned_thread
  end
  
  def test_add_thread_no_name
    post '/threads', {"name1" => "Don't forget"}.to_json
    assert_equal 400, last_response.status
  end 

  def test_get_thread_list
    get '/threads'
    assert_equal 200, last_response.status
  end
 
  def test_add_and_retrieve_thread

    thread = {
        "name" => "Add and retrieve thread test"
    }

    thread_id = create_a_new_thread(thread)

    returned_thread = retrieve_thread(thread_id)

    thread.each_key do |k|
      refute_nil returned_thread[k]
      assert_equal thread[k], returned_thread[k]
    end
  end

  def test_add_and_remove_threads
    thread = {
        "name" => "Add remove test"
    }

    thread_id = create_a_new_thread(thread)

    get '/threads/' + thread_id
    assert_equal 200, last_response.status

    delete '/threads/' + thread_id
    assert_equal 204, last_response.status

    get '/threads/' + thread_id
    assert_equal 404, last_response.status
  end
=begin
  def test_get_non_existent_thread
    get '/threads/gone' 
    assert_equal 404, last_response.status
  end

  def test_update_non_existent_thread
    thread = {
        "name" => "i dont exist"
    }

    put '/threads/thread_gone', thread.to_json
    assert_equal 404, last_response.status
  end

  def test_delete_non_existent_thread
    delete '/threads/thread_gone'
    assert_equal 404, last_response.status
  end
=end
end
