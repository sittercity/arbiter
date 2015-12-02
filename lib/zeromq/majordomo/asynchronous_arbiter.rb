require 'ffi-rzmq'

module Zeromq
  module Majordomo
    class AsynchronousArbiter
      INFINITE = -1

      def initialize(address, context, timeout_in_sec, md_service)
        @address = address
        @context = context
        @timeout = timeout_in_sec.to_i * 1000 #ms
        @md_service = md_service
      end

      def publish(method, params)
        sock = connect
        assert_zmq_ok(sock.send_strings(
          ['', 'MDPC01', @md_service, method.to_s, Marshal.dump(params)]
        ))
      ensure
        disconnect(sock)
      end

      private

      def connect
        sock = @context.socket(ZMQ::DEALER)
        assert_zmq_ok(sock.setsockopt(ZMQ::LINGER, INFINITE))
        assert_zmq_ok(sock.setsockopt(ZMQ::SNDTIMEO, @timeout))
        assert_zmq_ok(sock.connect(@address))
        sock
      end

      def disconnect(sock)
        assert_zmq_ok(sock.disconnect(@address))
        assert_zmq_ok(sock.close)
      end

      def assert_zmq_ok(rc)
        raise ZMQ::Util.error_string unless ZMQ::Util.resultcode_ok?(rc)
      end
    end
  end
end
