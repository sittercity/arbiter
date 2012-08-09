class Arbiter

  def initialize(listeners)
    @message_table = {}
    listeners.each do |listener|
      listener.subscribe_to.each do |channel|
        @message_table[channel] ||= []
        @message_table[channel] << listener
      end
    end
  end

  def publish(message, metadata)
    if @message_table[message] and ! @message_table[message].empty?
      @message_table[message].each do |listener|
        listener.notify(message, metadata)
      end
    end
  end

end
