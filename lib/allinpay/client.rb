require 'allinpay/helper/common'
require 'allinpay/api'
module Allinpay
  class Client
    include Api
    include Helper::Common

    attr_accessor :configurate, :conn

    def initialize(config)
      @configurate = config
      @conn = Faraday.new request_url, ssl: ssl_options
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

    def verify_signature?(res, result)
      signed = result["AIPG"]["INFO"]["SIGNED_MSG"]
      xml_body = res.encode('utf-8', 'gbk').gsub(/<SIGNED_MSG>.*<\/SIGNED_MSG>/, '')
      Signature.verify?(xml_body.encode('gbk', 'utf-8'), [signed].pack("H*"))
    end


  end
end
