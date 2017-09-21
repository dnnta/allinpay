module Allinpay
  module Service
    def self.connection(env, options)
      set_signature_infomation(options)
      ssl_options = {}
      if env.to_s == "development" || env.to_s == "test"
        ssl_options = {verify: false} 
      end
      klass = Class.new do
        include Allinpay::Service
        attr_accessor :gateway_url, :conn

        def initialize(env, ssl_options)
          @gateway_url = set_gateway_url(env)
          @conn = Faraday.new gateway_url, ssl: ssl_options
        end
      end.new(env, ssl_options)
    end

    def request(params)
      params[:INFO][:SIGNED_MSG] = Signature.generate(parse_xml(params)).unpack('H*').first
      body = parse_xml(params)
      response = conn.post do |req|
        req.headers['Content-Type'] = 'text/xml'
        req.body = body
      end
      return raise "HTTP Connection has error." if response.status != 200
      result = response.body
      result_xml = Hash.from_xml(result)
      return raise "Signature verify failed." if !verify_signature?(result, result_xml)
      return result_xml['AIPG']
    end

    private

    def verify_signature?(res, result)
      signed = result["AIPG"]["INFO"]["SIGNED_MSG"]
      xml_body = res.encode('utf-8', 'gbk').gsub(/<SIGNED_MSG>.*<\/SIGNED_MSG>/, '')
      Signature.verify?(xml_body.encode('gbk', 'utf-8'), [signed].pack("H*"))
    end

    def parse_xml(data, indent = 0)
      data_xml = data.to_xml(root: 'AIPG', skip_types: true, dasherize: false, indent: indent).sub('UTF-8', 'GBK')
      data_xml.encode! 'gbk','utf-8'
      data_xml
    end

    def set_gateway_url(env)
      if env.to_s == "development" || env.to_s == "test"
        return 'https://113.108.182.3/aipg/ProcessServlet'
      else
        return 'https://tlt.allinpay.com/aipg/ProcessServlet'
      end
    end

    def self.set_signature_infomation(options)
      raise "Allinpay private key not exists" if !File.exists?(options[:private_path])
      raise "Allinpay public key not exists" if !File.exists?(options[:public_path])
      Allinpay::Client.private_path = options[:private_path]
      Allinpay::Client.private_password = options[:private_password]
      Allinpay::Client.public_path = options[:public_path]
    end
  end
end
