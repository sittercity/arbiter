require 'zeromq/majordomo/asynchronous_arbiter'

describe Zeromq::Majordomo::AsynchronousArbiter do
  let(:zmq_context) { ZMQ::Context.new }
  let(:broker) { zmq_context.socket(ZMQ::ROUTER).tap { |s| s.bind(socket_uri) } }
  let(:socket_uri) { 'inproc://server' }
  let(:response_object) { {:foo => :bar} }
  let(:version) { 'some-version' }

  before { broker }

  after {
    broker.close
    zmq_context.terminate
  }

  subject { described_class.new(socket_uri, zmq_context, 5, version) }

  it 'sends an MDP client request on the reply socket' do
    client_thread = Thread.new do
      response = subject.publish('rpc-method', :foo => :body)
    end

    broker_thread = Thread.new do
      request = []
      broker.recv_strings(request)

      expect(request.first).to_not be_empty
      expect(request[1..-1]).to eq [
        '', 'MDPC01', version, 'rpc-method', Marshal.dump(:foo => :body)
      ]
    end

    client_thread.join
    broker_thread.join
  end

  it 'sends twice without blocking' do
    broker_thread = Thread.new do
      request = []
      broker.recv_strings(request)

      expect(request.first).to_not be_empty
      expect(request[1..-1]).to eq [
        '', 'MDPC01', version, 'some_method', Marshal.dump(:some_arg)
      ]

      request = []
      broker.recv_strings(request)

      expect(request.first).to_not be_empty
      expect(request[1..-1]).to eq [
        '', 'MDPC01', version, 'some_method', Marshal.dump(:some_arg)
      ]
    end

    subject.publish(:some_method, :some_arg)
    subject.publish(:some_method, :some_arg)
    broker_thread.join
  end

  it 'works with a Symbol method' do
    broker_thread = Thread.new do
      request = []
      broker.recv_strings(request)

      expect(request.first).to_not be_empty
      expect(request[1..-1]).to eq [
        '', 'MDPC01', version, 'some_method', Marshal.dump(:some_arg)
      ]
    end

    subject.publish(:some_method, :some_arg)
    broker_thread.join
  end
end
