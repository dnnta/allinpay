module Allinpay
  module ApiLoader
    def self.with(config)
      raise "Allinpay private key not exists" unless File.exists?(config.private_path)
      raise "Allinpay public key not exists" unless File.exists?(config.public_path)
      Allinpay::Client.new(config)
    end
  end
end