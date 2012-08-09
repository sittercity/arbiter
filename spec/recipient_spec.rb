require 'recipient'

describe Recipient do
  let(:recipient) { Recipient.from_id(1) }

  it 'recieves messages via email and sms' do
    recipient.available_channels.should == [:email, :sms]    
  end

  it 'specifies addresses to receive email and sms' do
    recipient.channels_with_addresses.should == {:email => "foo@bar.com", :sms => "123"}
  end
end
