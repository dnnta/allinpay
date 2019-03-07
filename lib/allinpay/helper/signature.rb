module Allinpay
  module Helper
    module Signature
      # 通联支付 参数加密
      # 
      # @param str [String] 待加密参数
      #
      # @return [String] 加密后信息
      def generate(str)
        private_file = File.open(configurate.private_path)
        private_key= OpenSSL::PKCS12.new(private_file, configurate.private_password).key.to_s
        rsa = OpenSSL::PKey::RSA.new private_key
        rsa.sign("sha1", str.force_encoding("GBK"))
      end

      # 通联支付 信息验证
      #
      # @param str [String] 待加密信息
      # @param sign [String] 签名
      #
      # @return [Boolean] 验证后信息
      def verify?(str, sign)
        public_file = File.open(configurate.public_path)
        public_key = OpenSSL::X509::Certificate.new(public_file).public_key.to_s
        rsa = OpenSSL::PKey::RSA.new(public_key)
        rsa.verify("sha1", sign, str)
      end

      def verify_signature?(res, result)
        signed = result["AIPG"]["INFO"]["SIGNED_MSG"]
        xml_body = res.encode('utf-8', 'gbk').gsub(/<SIGNED_MSG>.*<\/SIGNED_MSG>/, '')
        verify?(xml_body.encode('gbk', 'utf-8'), [signed].pack("H*"))
      end

    end
  end
end
