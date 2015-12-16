# Arbiter

An eventing gem.

[![Build Status](https://travis-ci.org/sittercity/arbiter.png)](https://travis-ci.org/sittercity/arbiter)

## Theory

To briefly explain, we want to separate the application/business logic from the framework and runtime. This project is structured so that the application and business rules live in /lib while the framework and runtime components live in /app. events.rb is the bootstrap that kicks off everything.

## Breakdown

### Arbiter

This is the messaging 'driver.' When the underlying message framework changes, this also must change.

#### Arbiter Drivers

To implement an arbiter, just extend the arbiter class and add a `self.publish` method:

```ruby
class ResqueArbiter < Arbiter
  def self.publish(message, metadata)
    Resque.enqueue(Arbiter, message, metadata)
  end
end
```

#### Setting Arbiter Listeners

You'll need to specify the classes to listen with on your arbiter driver. For example, if you were using the `ResqueArbiter`, you'd do this somewhere in your initialization of your application:

```ruby
ResqueArbiter.set_listeners([Classes, To, Listen, On])
```

### Eventer

This is the application-side eventing component. It is a singleton or statically invoked throughout the app and understands how to talk to the arbiter. In your application, you need to add an arbiter to the Eventer bus:

```ruby
Eventer.bus = ResqueArbiter
```

### Publishing Events

It publish an event, use the `Eventer.post` method. It takes two arguments:

 1. The event name
 2. A hash of arguments to pass

For example

```ruby
Eventer.post(:account_created, account.to_hash)
```

Just a side note, it's not advised to push symbols into events, as they likely won't be received as symbols on the other side.

## Listening on events

To create a class that listens on an event, it must conform to some conventions:

  - have a `@subscribe_to` array
  - have a `notify(event, args)` method

The `@subscribe_to` array tells the arbiter which events you want this class to listen for

The `notify` method should inspect the `event` that comes in, and act accordingly. For example:

```ruby
class Postmaster

  @subscribe_to = [:hello]

  class << self
    attr_accessor :router
    attr_accessor :record
    attr_reader :subscribe_to
  end

  def self.send_hello(recipient_id)
    # Send some email here
  end

  def self.notify(event, args)
    case event
    when :hello
      send_hello(*args)
    end
  end
end
```

## Available Arbiter Drivers

These are the provided arbiter drivers:

### In-Memory (Arbiter)

The in-memory arbiter is the default, simplest driver. This is an in-memory arbiter, and is only really useful for testing. If you use this in production, it will handle events in-process, which probably isn't what you want.

### Resque (ResqueArbiter)

This is an Arbiter implementation that uses a Resque backend. You'll need a Resque worker running to process events. See the resque manual for details on this.

### ZeroMQ Majordomo (Zeromq::Majordomo::AsynchronousArbiter)

This is an Arbiter that uses ZeroMQ and the [Majordomo Protocol](http://rfc.zeromq.org/spec:7) to send it's messages. It submits asynchronously to dispatch work via a broker (which is not provided by this gem). You must also have majordomo workers receiving and processing the work (workers are also not provided).

#### Configuring Zeromq::Majordomo::AsynchronousArbiter

You'll need to setup some configuration in your app to use this arbiter.

* Address: The address of the Majordomo broker
* ZMQ Context: the ZMQ context implementation
* Timeout: timeout in seconds
* MD Service: The service name to use with Majordomo. This is how messages are routed.

Example:

```ruby
require 'arbiter'
require 'ffi-rzmq'

class ZeromqConfig
  arbiter = Zeromq::Majordomo::AsynchronousArbiter.new(
              "tcp://192.168.1.1:9292",
              ZMQ::Context.new,
              5,
              "some-service-name-v1"
           )
end
```
