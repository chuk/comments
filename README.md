## Event API

Event API is a simple Sinatra app using Datamapper and SQLite that
allows the saving, updating and retrieval of simple 'events'.

### Features

* Illustrates creation of an API with Sinatra
* Shows how to create a data model using Datamapper and SQLite
* Shows how to write tests for the web application

### Install

You'll need Ruby 1.9.3 to run, and Bundler to install the necessary gems. 

    $ bundle
    $ rackup
    >> Thin web server (v1.5.0 codename Knife)
    >> Maximum connections set to 1024
    >> Listening on 0.0.0.0:9292, CTRL+C to stop

Your simple event api is now running on port 9292 on you local machine.

### Running the tests

Once you have the code installed, running the tests is a simple as 

    $ bundle
    $ bundle exec ruby test/event_test.rb

Running the tests will produce a test coverage file `coverage/index.html` which shows 
all the pieces of code that were hit during the test run.

### API

This example code has a simple API for creating, updating and deleting 'events'.

*Add an event to the database:*

    $ curl -X POST -d '{"name": "event"}' http://localhost:9292/events


*Retrieve an event from the database:*

    $ curl -X GET http://localhost:9292/events/1

returns JSON representation of event with id '1':

    {
       "id" :  1,
       "name" :  "event",
       "createDate"  :  "2013-02-24T13:36:12+00:00",
       "updateDate"  :  "2013-02-24T13:36:12+00:00"
    }

*Retrieve an event list the database:*

	$ curl -X GET http://localhost:9292/events/1

returns

	[{
    "id": 1,
    "name": "event1",
    "createDate": null,
    "updateDate": null
    },{
    "id": 2,
    "name": "event2",
    "createDate": null,
    "updateDate": null
    }]
	

*Updating an event in the database:*

    $ curl -X PUT -d http://localhost:9292/events/1

will update the content of note 1. If you get a 404, there isn't a note 1. If you get a 400, then you haven't given any arguments in the body of the request, i.e. changes to be made to the note. It should be along the lines of


    {
       "name" :  "Event 5"
    }

*Deleting an event from the database:*

    curl -X DELETE http://localhost:9292/events/2



