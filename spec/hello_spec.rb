require 'hello'

describe Hello do
  context '#hello' do
    it 'sends an event :hello to the eventer' do
      Eventer.should_receive(:event).with(:hello)
      Hello.new.say
    end
  end
end
