class Router
  def send_message(message, opts={})
    address = opts[:to]
    channel = opts[:via]
    deliver_email "#{channel} <to:#{address}>: #{message.to_s}"
  end

  def deliver_email(text)
    puts text
  end
end
