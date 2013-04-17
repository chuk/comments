require 'rubygems'
require 'active_support'
require 'sinatra'
require 'json'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'
require 'mongoid'

if development? # This is set by default, override with `RACK_ENV=production rackup`
  require 'sinatra/reloader'
  require 'debugger'
  Debugger.settings[:autoeval] = true
  Debugger.settings[:autolist] = 1
  Debugger.settings[:reload_source_on_change] = true
end

configure :development, :production do
  Mongoid.load!(File.expand_path(File.dirname(__FILE__)) + "/mongoid.yml")
  #set :datamapper_url, "sqlite3://#{File.dirname(__FILE__)}/thread.sqlite3"
end
configure :test do
  Mongoid.load!(File.expand_path(File.dirname(__FILE__)) + "/mongoid.yml")
  #set :datamapper_url, "sqlite3://#{File.dirname(__FILE__)}/thread-test.sqlite3"
end

before do
  content_type 'application/json'
end

#DataMapper.setup(:default, settings.datamapper_url)

class Thready

  include Mongoid::Document
  #include DataMapper::Resource

  field :name, type: String
  #Thready.property(:id, Serial)
  #Thready.property(:name, Text)
  #Thready.property(:createDate, DateTime)
  #Thready.property(:updateDate, DateTime)

  def to_json(*a)
   {
      'id' => self.id,
      'name' => self.name
      #'createDate' => self.createDate,
      #'updateDate' => self.updateDate
   }.to_json(*a)
  end
end

=begin
class Thready
  include DataMapper::Resource

  Thready.property(:id, Serial)
  Thready.property(:name, Text)
  Thready.property(:createDate, DateTime)
  Thready.property(:updateDate, DateTime)

  def to_json(*a)
   {
      'id' => self.id,
      'name' => self.name,
      'createDate' => self.createDate,
      'updateDate' => self.updateDate
   }.to_json(*a)
  end
end
=end

DataMapper.finalize
#Thready.auto_upgrade!

get '/' do 
	'Hello World2'
end

get '/threads/:id' do
	#puts "DEBUG: Getting thread with ID: #{params[:id]}"
	
	begin
		thread = Thready.find(params[:id])
	rescue Mongoid::Errors::DocumentNotFound
		puts "DEBUG: Thread not found in database."
	end

	if thread.nil? then
		status 404
	else
		status 200
		body(thread.to_json)
	end
end

get '/threads' do
	threads = Thready.all
	thread_count = Thready.count

	#puts "DEBUG: Thread count: " + thread_count.to_s

	thread_list = Array.new

	threads.each do |a|
	  	thread_list << a
	end

	body(thread_list.to_json)
end

delete '/threads/:id' do
	puts "DEBUG: Delete thread with ID: #{params[:id]}"
	thread = Thready.find(params[:id])
	if thread.nil? then
		status 404
	else
		if thread.destroy then
			status 204	
		else
			status 500
		end
	end
end

post '/threads' do
	data = JSON.parse(request.body.read)
	puts "*** Saving thread: \"" + data['name'].to_s + "\""

	if data.nil? or !data.has_key?('name')
	 	status 400
	else
	 	thread = Thready.create(:name => data['name'],:createDate => Time.now)
	 	thread.save!
	 	status 200

	 	puts "*** Saved thread: ID = " + thread.id.to_s
	 	response.headers['Location'] = "/threads/#{thread.id.to_s}"
	 	body(thread.to_json)
	end
end

put '/threads/:id' do

	puts "DEBUG: updating thread with ID: #{params[:id]}"

	data = JSON.parse(request.body.read)

	if data.nil?
	 	status 400
	else
	 	thread = Thread.get(params[:id])

		if thread.nil?
			status 404
		else
			updated = false
			%w(name).each do |k|
				if data.has_key?(k)
					puts(k.to_s)
					thread[k] = data[k]
					updated = true
				end
			end
			if updated then
				thread['updateDate'] = Time.now
				if !thread.save then
					status 500
				else
					status 201
				end
			end
		end
	 	
	end
end