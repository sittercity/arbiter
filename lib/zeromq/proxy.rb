require 'ffi-rzmq'

module Zeromq
  class Proxy
    def initialize(frontend, backend)
      @frontend = frontend
      @backend = backend
    end

    def execute
      context = ZMQ::Context.new

      frontend = context.socket(ZMQ::PULL)
      bound = frontend.bind(@frontend)

      raise 'Error starting frontend!' unless bound == 0

      backend = context.socket(ZMQ::PUSH)
      bound = backend.bind(@backend)

      raise 'Error starting backend!' unless bound == 0

      ZMQ::Device.new(ZMQ::QUEUE,frontend,backend)
    end
  end
end
