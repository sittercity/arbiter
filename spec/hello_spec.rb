require 'hello'
require 'eventer'

describe Hello do
  context '#hello' do
    it 'sends an event :hello to the eventer' do
      Eventer.should_receive(:post).with(:hello, 5).and_return(true)
      Hello.new.say
    end
  end
end
