require 'resque'

class ResqueArbiter
  def self.publish(message, metadata)
    Resque.enqueue(Arbiter, message, metadata)
  end
end
