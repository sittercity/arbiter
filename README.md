# Events

This is merely a quick mockup of how an event system ought to work. It is not a framework, not an enforced interface, and not a gem.

## Theory

To briefly explain, we want to separate the application/business logic from the framework and runtime. This project is structured so that the application and business rules live in /lib while the framework and runtime components live in /app. events.rb is the bootstrap that kicks off everything.

## To Run

In one terminal (with redis running)
> bundle install
> QUEUE=arbiter bundle exec rake resque:work

In another
> irb -I.
> require 'events.rb'
> Hello.new.say

You should see two "messages" being sent in the resque terminal session (you may need to wait as long as 5 seconds).

## Breakdown

### Arbiter
This is the messaging 'driver.' When the underlying message framework changes, this also must change.

### Eventer
This is the application-side eventing component. It is a singleton or statically invoked throughout the app and understands how to talk to the arbiter.

### Postmaster
This is an example of a listener within the application. It registers with arbiter in events.rb, so the arbiter knows how to invoke it.

### Hello
A "normal" application class. Only needs to know about the eventer (no knowledge of listeners to it's event, nor to how event is propogated).

## Peripheral
Several classes were implemented in order to show how a mailing framework might work. This will be a subject of a future discussion, so they were not fully fleshed out.

### Router
The application component that knows how to deliver messages.

### Recipient
A role (of sorts) that specifies whether a user can receive different type of messages and at what address.

### Record
Logging facility for the postmaster.

Looking forward to discussion on August 22.
