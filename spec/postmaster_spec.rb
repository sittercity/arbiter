require 'postmaster'

describe Postmaster do
  it 'subscribes to hello and goodbye' do
    Postmaster.subscribe_to.should == [:hello, :goodbye]
  end

  context '#notify' do
    it 'with :hello invokes the send_hello method with hello and arguments' do
      Postmaster.should_receive(:send_hello).with(:foobar)
      Postmaster.notify(:hello, [:foobar])
    end
  end

  context '#send_hello' do
    let(:router) { double(:router, :send_message => true) }
    let(:recipient) { double(:recipient, :channels_with_addresses => {:sms => "123"}) }

    before(:each) do
      Recipient.stub(:from_id => recipient)
      Postmaster.router = router
    end

    it 'sends via sms when the recipient receives sms' do
      router.should_receive(:send_message).with(:hello, {:via => :sms, :to => "123"}).and_return(true)
      Postmaster.send_hello(123)
    end
  end
end
