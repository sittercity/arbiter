require 'resque'
class Arbiter

  @queue = :arbiter

  def self.perform(message, metadata)
    message = message.to_sym
    if @message_table[message] and ! @message_table[message].empty?
      @message_table[message].each do |listener|
        listener.notify(message, metadata)
      end
    end
  end

  def self.set_listeners(listeners)
    @message_table = {}
    listeners.each do |listener|
      listener.subscribe_to.each do |channel|
        @message_table[channel] ||= []
        @message_table[channel] << listener
      end
    end
  end

  def self.publish(message, metadata)
    Resque.enqueue(Arbiter, message, metadata)
  end
end
