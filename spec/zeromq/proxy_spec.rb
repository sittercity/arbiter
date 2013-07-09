require 'zeromq/proxy'

describe Zeromq::Proxy do
  let(:context) { double(:context) }
  let(:frontend_config) { 'tcp://0.0.0.0:9000' }
  let(:backend_config) { 'tcp://0.0.0.0:9001' }

  subject { described_class.new(frontend_config, backend_config) }

  before :each do
    ZMQ::Context.stub(:new => context)
  end

  it 'listens' do
    frontend = double(:frontend)
    frontend.should_receive(:bind).with(frontend_config).and_return(0)
    backend = double(:backend)
    backend.should_receive(:bind).with(backend_config).and_return(0)

    context.should_receive(:socket).with(ZMQ::PULL).and_return(frontend)
    context.should_receive(:socket).with(ZMQ::PUSH).and_return(backend)

    ZMQ::Device.should_receive(:new).with(ZMQ::QUEUE, frontend, backend)

    subject.execute
  end

  it 'raises an error if binding the frontend fails' do
    frontend = double(:frontend)
    frontend.should_receive(:bind).with(frontend_config).and_return(-1)

    context.stub(:socket).with(ZMQ::PULL).and_return(frontend)

    lambda { subject.execute }.should raise_error { |e|
      e.message.should == 'Error starting frontend!'
    }
  end

  it 'raises an error if binding the backend fails' do
    frontend = double(:frontend)
    frontend.should_receive(:bind).with(frontend_config).and_return(0)
    backend = double(:backend)
    backend.should_receive(:bind).with(backend_config).and_return(-1)

    context.stub(:socket).with(ZMQ::PULL).and_return(frontend)
    context.stub(:socket).with(ZMQ::PUSH).and_return(backend)

    lambda { subject.execute }.should raise_error { |e|
      e.message.should == 'Error starting backend!'
    }
  end
end
