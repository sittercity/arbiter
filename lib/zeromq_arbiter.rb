require 'arbiter'
require 'ffi-rzmq'
require 'multi_json'

class ZeromqArbiter < Arbiter

  class << self
    attr_accessor :frontend, :logger
  end

  def self.publish(message, metadata)
    context = ZMQ::Context.new

    outbound = context.socket(ZMQ::PUSH)
    outbound.connect(frontend)

    outbound.send_string(
      MultiJson.dump(
        :message => message,
        :metadata => metadata
      )
    )

    outbound.close
    context.terminate
  end

  def listen(proxy)
    raise 'Must provide proxy location!' unless proxy

    ctx = ZMQ::Context.new
    socket = ctx.socket(ZMQ::PULL)
    rc = socket.connect(proxy)

    raise "Could not connect to #{proxy}!" unless rc == 0

    log :info, "Connected to #{proxy}"

    while true
      msg = ''
      rc = socket.recv_string(msg)

      if error_check(rc)
        break
      else
        process_message(msg)
      end
    end

    socket.close
    ctx.terminate
  end

  protected

  def log(type, msg)
    if self.class.logger
      self.class.logger.send(type, msg)
    end
  end

  def process_message(message)
    message = MultiJson.decode(message)
    log :info, "Processing: #{message}"

    begin
      self.class.perform(message['message'].to_sym, symbolize_nested_keys(message['metadata']))
    rescue Exception => e
      log :error, e
    end
  end

  def error_check(rc)
    if ZMQ::Util.resultcode_ok?(rc)
      false
    else
      log :error, "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
      caller(1).each { |callstack| log :error, callstack }
      true
    end
  end

  def symbolize_nested_keys(data)
    case data
    when Hash
      data.map {|k, v|
        {k.to_sym => symbolize_nested_keys(v)}
      }.inject({}) { |coll, symbol_key_hash|
        coll.merge(symbol_key_hash)
      }
    when Array
      data.collect { |a|
        symbolize_nested_keys(a)
      }
    else
      data
    end
  end
end
