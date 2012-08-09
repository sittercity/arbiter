require_relative '../../app/arbiter'

describe Arbiter do
  let(:observer) { double(:observer, :subscribe_to => [:foo, :bar], :notify => true) }
  let(:arbiter) { Arbiter.new([observer]) }

  context '#publish' do
    it 'notifies observer of messages for which it is registered' do
      observer.should_receive(:notify).with(:foo, [1, 2])
      arbiter.publish(:foo, [1, 2])
    end

    it 'does not notify observers of messages for which they are not registered' do
      observer.should_not_receive(:notify)
      arbiter.publish(:baz, [])
    end
  end
end
