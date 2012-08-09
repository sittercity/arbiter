require 'eventer'

describe Eventer do
  let(:mock_bus) { double('bus') }
  before(:each) do
    Eventer.bus = mock_bus
  end

  it 'silently fails when bus unset' do
    Eventer.bus = nil
    lambda { Eventer.post(:foobar, :a) }.should_not raise_error
  end

  it 'posts messages to the bus' do
    mock_bus.should_receive(:publish).with(:foobar, [])
    Eventer.post(:foobar)
  end

  it 'posts arbitrary messages to the bus' do
    mock_bus.should_receive(:publish).with(:foobar, [1,2])
    Eventer.post(:foobar, 1, 2)
  end
end
