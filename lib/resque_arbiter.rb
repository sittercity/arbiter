require 'resque'
require 'arbiter'

class ResqueArbiter < Arbiter
  @queue = :arbiter

  def self.publish(message, metadata)
    Resque.enqueue(ResqueArbiter, message, metadata)
  end
end
