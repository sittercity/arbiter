class Eventer

  class << self; attr_accessor :bus end

  def self.post(message, *args)
    bus.publish(message, args)
  end

end
