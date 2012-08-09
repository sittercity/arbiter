require_relative './recipient'

class Postmaster

  @subscribe_to = [:hello, :goodbye]

  class << self
    attr_accessor :router
    attr_accessor :record
    attr_reader :subscribe_to
  end

  def self.send_hello(recipient_id)
    recipient = Recipient.from_id(recipient_id)
    recipient.channels_with_addresses.each do |channel, address|
      router.send_message(:hello, {:via => channel, :to => address})
    end
  end

  def self.notify(message, args)
    case message
    when :hello
      send_hello(*args)
    end
  end
end
