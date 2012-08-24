require 'arbiter'

describe Arbiter do
  let(:observer) { double(:observer, :subscribe_to => [:foo, :bar], :notify => true) }
  let(:arbiter) { Arbiter }

  before(:each) do
    arbiter.set_listeners([observer])
  end

  context '#perform' do
    it 'notifies observer of messages for which it is registered' do
      observer.should_receive(:notify).with(:foo, [1, 2])
      arbiter.perform(:foo, [1, 2])
    end

    it 'does not notify observers of messages for which they are not registered' do
      observer.should_not_receive(:notify)
      arbiter.perform(:baz, [])
    end
  end

  context '#publish' do
    it 'publishes a message' do
      arbiter.should_receive(:perform).with(:a, [1,2])
      arbiter.publish(:a, [1,2])
    end
  end
end
