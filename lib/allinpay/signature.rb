require 'openssl'

module Allinpay
  class Signature
    def self.generate(str)
      private_file = File.open(Allinpay::Client.private_path)
      private_key= OpenSSL::PKCS12.new(private_file, Allinpay::Client.private_password).key.export
      rsa = OpenSSL::PKey::RSA.new private_key
      rsa.sign("sha1", str.force_encoding("GBK"))
    end

    def self.verify?(str, sign)
      public_file = File.open(Allinpay::Client.public_path)
      public_key = OpenSSL::X509::Certificate.new(public_file).public_key.export
      rsa = OpenSSL::PKey::RSA.new(public_key)
      rsa.verify("sha1", sign, str)
    end
  end
end
