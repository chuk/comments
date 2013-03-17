require 'rubygems'
require 'sinatra'
require 'json'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'

if development? # This is set by default, override with `RACK_ENV=production rackup`
  require 'sinatra/reloader'
  require 'debugger'
  Debugger.settings[:autoeval] = true
  Debugger.settings[:autolist] = 1
  Debugger.settings[:reload_source_on_change] = true
end

configure :development, :production do
  set :datamapper_url, "sqlite3://#{File.dirname(__FILE__)}/event.sqlite3"
end
configure :test do
  set :datamapper_url, "sqlite3://#{File.dirname(__FILE__)}/event-test.sqlite3"
end

before do
  content_type 'application/json'
end

DataMapper.setup(:default, settings.datamapper_url)

class Event
  include DataMapper::Resource

  Event.property(:id, Serial)
  Event.property(:name, Text)
  Event.property(:createDate, DateTime)
  Event.property(:updateDate, DateTime)

  def to_json(*a)
   {
      'id'      => self.id,
      'name' => self.name,
      'createDate' => self.createDate,
      'updateDate' => self.updateDate
   }.to_json(*a)
  end
end

DataMapper.finalize
Event.auto_upgrade!

get '/' do 
	'Hello World2'
end

get '/events/:id' do
	puts "*** got number #{params[:id]}"
	event = Event.get(params[:id])
	if event.nil? then
		status 404
	else
		status 200
		body(event.to_json)
	end
end

get '/events' do
	events = Event.all
	event_count = Event.count

	puts "*** event count " + event_count.to_s

	event_list = Array.new

	events.each do |a|
	  	event_list << a
	end

	body(event_list.to_json)
end

delete '/events/:id' do
	puts "*** delete number #{params[:id]}"
	event = Event.get(params[:id])
	if event.nil? then
		status 404
	else
		if event.destroy then
			status 204	
		else
			status 500
		end
	end
end

post '/events' do
	data = JSON.parse(request.body.read)
	puts "*** save event " + data['name'].to_s

	if data.nil? or !data.has_key?('name')
	 	status 400
	else
	 	event = Event.create(:name => data['name'],:createDate => Time.now)
	 	event.save
	 	status 200
	 	puts "*** saved event " + event.id.to_s
	 	response.headers['Location'] = "/events/#{event['id']}"
	 	body(event.to_json)
	end
end

put '/events/:id' do

	puts "*** update event #{params[:id]}"

	data = JSON.parse(request.body.read)

	if data.nil?
	 	status 400
	else
	 	event = Event.get(params[:id])

		if event.nil?
			status 404
		else
			updated = false
			%w(name).each do |k|
				if data.has_key?(k)
					puts(k.to_s)
					event[k] = data[k]
					updated = true
				end
			end
			if updated then
				event['updateDate'] = Time.now
				if !event.save then
					status 500
				else
					status 201
				end
			end
		end
	 	
	end
end



