class Recipient
  def self.from_id(id)
    new
  end

  def available_channels
    channels_with_addresses.keys
  end

  def channels_with_addresses
    {email: "foo@bar.com", sms: "123"}
  end
end
