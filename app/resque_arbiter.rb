require 'resque'

class ResqueArbiter < Arbiter
  def self.publish(message, metadata)
    Resque.enqueue(Arbiter, message, metadata)
  end
end
