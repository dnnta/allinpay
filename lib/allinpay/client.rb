require 'allinpay/api'
require 'allinpay/helper/service'
require 'allinpay/helper/signature'

module Allinpay
  class Client
    include Api
    include Helper::Service
    include Helper::Signature

    attr_accessor :configurate, :conn, :request_xml, :response_xml

    def initialize(config)
      @configurate = config
      @conn = Faraday.new request_url, ssl: ssl_options
    end

    def request(params)
      params[:INFO][:SIGNED_MSG] = generate(parse_xml(params)).unpack('H*').first
      body = parse_xml(params)

      begin
        response = conn.post do |req|
          req.headers['Content-Type'] = 'text/xml'
          req.options.timeout = 60 # open/read timeout in seconds
          req.body = body
        end
        @response_xml = response.body
        result_xml = Hash.from_xml(response_xml)
        if !verify_signature?(response_xml, result_xml)
          return {status: 'fail', msg: '返回验签不一致'}
        end
        result_wrap
      rescue Exception => e
        return {status: 'fail', msg: '请求出错'}
      end
    end

  end
end
