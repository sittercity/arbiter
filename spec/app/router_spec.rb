require_relative '../../app/router'

describe Router do
  let(:router) { Router.new }

  context 'sends messages' do
    it 'by putting them to the screen' do
      router.should_receive(:deliver_email).with("email <to:foo@bar.com>: hello")
      router.send_message(:hello, :via => :email, :to => "foo@bar.com")
    end
  end
end
