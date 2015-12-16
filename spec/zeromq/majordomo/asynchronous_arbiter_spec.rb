require 'zeromq/majordomo/asynchronous_arbiter'

describe Zeromq::Majordomo::AsynchronousArbiter do
  let(:response_object) { {:foo => :bar} }

  let(:socket_uri) { 'inproc://server' }
  let(:zmq_context) { double(:context, socket: socket) }
  let(:version) { 'some-version' }

  let(:socket) { double(:socket) }

  subject { described_class.new(socket_uri, zmq_context, 5, version) }

  context 'successful connect' do
    before :each do
      zmq_context.should_receive(:socket).with(ZMQ::DEALER).and_return(socket)
      socket.should_receive(:setsockopt).at_least(:once).with(ZMQ::LINGER, -1).and_return(0)
      socket.should_receive(:setsockopt).at_least(:once).with(ZMQ::SNDTIMEO, 5000).and_return(0)
      socket.should_receive(:connect).at_least(:once).with(socket_uri).and_return(0)

      socket.should_receive(:disconnect).at_least(:once).with(socket_uri).and_return(0)
      socket.should_receive(:close).at_least(:once).and_return(0)
    end

    it 'sends an MDP client request on the reply socket' do
      socket.should_receive(:send_strings).with([
        '', 'MDPC01', version, 'rpc-method', Marshal.dump(:foo => :body)
      ]).and_return(0)

      subject.publish('rpc-method', :foo => :body)
    end

    it 'sends twice without blocking' do
      socket.should_receive(:send_strings).with([
        '', 'MDPC01', version, 'some_method', Marshal.dump(:some_arg)
      ]).at_least(2).times.and_return(0)

      subject.publish(:some_method, :some_arg)
      subject.publish(:some_method, :some_arg)
    end

    it 'works with a Symbol method' do
      socket.should_receive(:send_strings).with([
        '', 'MDPC01', version, 'some_method', Marshal.dump(:some_arg)
      ]).times.and_return(0)

      subject.publish(:some_method, :some_arg)
    end
  end

  it 'does not attempt disconnect if socket connection failed' do
    zmq_context.should_receive(:socket).and_raise(StandardError)
    lambda { subject.publish(:some_method, :some_arg) }.should raise_error(StandardError)
  end
end
