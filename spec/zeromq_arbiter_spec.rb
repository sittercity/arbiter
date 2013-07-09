require 'zeromq_arbiter'

describe ZeromqArbiter do
  let(:message) { :test }
  let(:metadata) { { :the => :data } }

  let(:zmq_context) { double(:zmq_context) }
  let(:socket) { double(:zmq_socket) }

  let(:frontend) { 'tcp://0.0.0.0:9000' }

  subject {
    described_class.frontend = frontend

    described_class
  }

  before :each do
    ZMQ::Context.stub(:new => zmq_context)
  end

  it 'sends a message to a zmq socket' do
    zmq_context.should_receive(:socket).with(ZMQ::PUSH).and_return(socket)
    socket.should_receive(:connect).with(frontend)
    socket.should_receive(:close)

    socket.should_receive(:send_string).with(MultiJson.dump(:message => message, :metadata => metadata))
    subject.publish(message, metadata)
  end

  context :listen do
    subject { described_class.new }

    it 'receives a message and pushes it to the listener classes' do
      zmq_context.should_receive(:socket).with(ZMQ::PULL).and_return(socket)
      socket.should_receive(:connect).with(frontend).and_return(0)
      socket.should_receive(:close)
      msg = ''
      return_values = [0, -1].to_enum
      socket.stub(:recv_string) do |msg|
        msg.concat(MultiJson.dump(:message => message, :metadata => metadata))
        return_values.next
      end

      described_class.should_receive(:perform).with(message, {:the => 'data'})

      subject.listen(frontend)
    end

    it 'raises an error if connect fails' do
      zmq_context.should_receive(:socket).with(ZMQ::PULL).and_return(socket)
      socket.should_receive(:connect).with(frontend).and_return(-1)

      lambda { subject.listen(frontend) }.should raise_error {|e|
        e.message.should == "Could not connect to #{frontend}!"
      }
    end

    it 'logs an error if recieving fails' do
      logger = double(:logger, :info => true)
      described_class.logger = logger

      logger.should_receive(:error).any_number_of_times

      zmq_context.should_receive(:socket).with(ZMQ::PULL).and_return(socket)
      socket.should_receive(:connect).with(frontend).and_return(0)
      socket.should_receive(:close)
      socket.stub(:recv_string).and_return(-1)

      subject.listen(frontend)
    end

    it 'logs an error if task perform raises an exception' do
      class PerformError < Exception; end

      logger = double(:logger, :info => true, :error => true)
      described_class.logger = logger

      logger.should_receive(:error) do |e|
        e.should be_a PerformError
      end

      zmq_context.should_receive(:socket).with(ZMQ::PULL).and_return(socket)
      socket.should_receive(:connect).with(frontend).and_return(0)
      socket.should_receive(:close)

      return_values = [0, -1].to_enum
      socket.stub(:recv_string) do |msg|
        msg.concat(MultiJson.dump(:message => message, :metadata => metadata))
        return_values.next
      end

      described_class.stub(:perform).and_raise(PerformError)

      subject.listen(frontend)
    end
  end
end
