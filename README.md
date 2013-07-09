# Arbiter

An eventing gem.

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

### ZeroMQ (ZeromqArbiter)

This is an Arbiter that uses ZeroMQ to send it's messages. This is by far the most advanced and powerful implementation, as you can use the power of zmq to setup any kind of messaging architecture you want.

#### Running the backend

To run the backend, you'll need to start two processes:

 - `rake "arbiter:proxy[frontend_uri,backend_uri]"`
 - `rake "arbiter:worker[backend_uri]"`

The `frontend_uri` and `backend_uri` values above should conform to standard zmq addresses. You can use tcp, udp, ipc, or anything else that zmq supports. You must start the proxy first, and then connect the workers to the proxy. This allows you to scale the workers up and down as you see fit. For a light application, you'll probably only need one worker, but for very busy applications, you might need much more than that.

#### Configuring ZeromqArbiter

You'll need to setup some configuration in your app to use zeromq.

Set the backend worker: `ZeromqArbiter.frontend = 'frontend_uri'`

The address should be the frontend location of your proxy.

You can also set a logger for it if you wish: `ZeromqArbiter.logger = Logger`
