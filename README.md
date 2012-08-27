# Events

An eventing gem.

## Theory

To briefly explain, we want to separate the application/business logic from the framework and runtime. This project is structured so that the application and business rules live in /lib while the framework and runtime components live in /app. events.rb is the bootstrap that kicks off everything.

## Breakdown

### Arbiter
This is the messaging 'driver.' When the underlying message framework changes, this also must change.

#### Arbiter Drivers

To implement an arbiter, just extend the arbiter class and add a `self.publish` method:

  class ResqueArbiter < Arbiter
    def self.publish(message, metadata)
      Resque.enqueue(Arbiter, message, metadata)
    end
  end

#### Setting Arbiter Listeners

  ResqueArbiter.set_listeners([Classes, To, Listen, On])

### Eventer
This is the application-side eventing component. It is a singleton or statically invoked throughout the app and understands how to talk to the arbiter. In your application, you need to add an arbiter to the Eventer bus:

  Eventer.bus = ResqueArbiter

## Listening on events

To create a class that listens on an event, it must conform to some conventions:

  - have a `@subscribe_to` array
  - have a `notify(event, args)` method

The `@subscribe_to` array tells the arbiter which events you want this class to listen for

The `notify` method should inspect the `event` that comes in, and act accordingly. For example:

  class Postmaster

    @subscribe_to = [:hello]

    class << self
      attr_accessor :router
      attr_accessor :record
      attr_reader :subscribe_to
    end

    def self.send_hello(recipient_id)
    end

    def self.notify(event, args)
      case event
      when :hello
        send_hello(*args)
      end
    end
  end
