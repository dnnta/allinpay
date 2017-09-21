module Allinpay
  class Client
    attr_accessor :merchant, :username, :password, :env, :gateway_url, :conn

    class << self
      attr_accessor :private_path, :public_path, :private_password
    end

    def initialize(options)
      @merchant = options[:merchant]
      @username = options[:username]
      @password = options[:password]
      @env = options[:env] || 'development'
      @gateway_url = set_gateway_url(env)
      set_signature_infomation(options)
      @conn = set_connection
    end

    # 通联支付单笔实时支付
    def pay
    end

    # 通联支付批量付款
    def batch_pay(trans, options = {})
      details = []
      index = 1
      info = set_infomation('100002', {LEVEL: 9})
      trans_sum = {
        BUSINESS_CODE: '09900' , 
        MERCHANT_ID: merchant, 
        SUBMIT_TIME: timestamps
      }
      trans_sum[:TOTAL_SUM] = trans.inject(0) do |sum, item|
        sn = index.to_s.rjust(4, '0')
        amount =  (item[:amount].to_f * 100).to_i
        details << {
          SN: sn,
           E_USER_CODE: 1,
           BANK_CODE: item[:bank_code],
           ACCOUNT_TYPE: item[:account_type],
           ACCOUNT_NO:  item[:account_number],
           ACCOUNT_NAME: item[:account_name],
           ACCOUNT_PROP: item[:account_prop],
           AMOUNT: amount
        }
        index += 1
        amount + sum
      end
      trans_sum[:TOTAL_ITEM] = index - 1
      params = { INFO: info, BODY: { TRANS_SUM: trans_sum, TRANS_DETAILS: details}}
      info[:SIGNED_MSG] = Signature.generate(parse_xml(params)).unpack('H*').first
      request_params = { INFO: info, BODY: { TRANS_SUM: trans_sum, TRANS_DETAILS: details}}
      res = pay_request(parse_xml(request_params))
      result = Hash.from_xml(res)
      if verify_signature?(res, result)
        return result
      else
        p "error"
      end
    end

    def query_batch_pay(sn)
      info = set_infomation('200004')
      query_body = { MERCHANT_ID: merchant, QUERY_SN: sn, type: '1'}
      params = { INFO: info, QTRANSREQ: query_body }
      info[:SIGNED_MSG] = Signature.generate(parse_xml(params)).unpack('H*').first
      request_params = { INFO: info, QTRANSREQ: query_body }
      res = pay_request(parse_xml(request_params))
      result = Hash.from_xml(res)
      if verify_signature?(res, result)
        return result
      else
        p "error"
      end
    end

    private

    def set_infomation(code, options = {})
      {
        TRX_CODE: code,
        VERSION: '03', 
        DATA_TYPE: '2',
        USER_NAME: username, 
        USER_PASS: password, 
        REQ_SN: req_sn
      }.merge(options)

    end

    def verify_signature?(res, result)
      signed = result["AIPG"]["INFO"]["SIGNED_MSG"]
      xml_body = res.encode('utf-8', 'gbk').gsub(/<SIGNED_MSG>.*<\/SIGNED_MSG>/, '')
      Signature.verify?(xml_body.encode('gbk', 'utf-8'), [signed].pack("H*"))
    end

    def pay_request(body)
      result = conn.post do |req|
        req.headers['Content-Type'] = 'text/xml'
        req.body = body
      end
      return result.body
    end

    def set_connection
      ssl_options = {}
      if env.to_s == "development" || env.to_s == "test"
        ssl_options = {verify: false} 
      end
      conn = Faraday.new gateway_url, ssl: ssl_options
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

    def set_signature_infomation(options)
      raise "Allinpay private key not exists" if !File.exists?(options[:private_path])
      raise "Allinpay public key not exists" if !File.exists?(options[:public_path])
      Allinpay::Client.private_path = options[:private_path]
      Allinpay::Client.private_password = options[:private_password]
      Allinpay::Client.public_path = options[:public_path]
    end

     def req_sn
       merchant + timestamps + rand(1000).to_s.ljust(4, '0')
     end
   
     def timestamps
       Time.now.strftime('%Y%m%d%H%M%S')
     end
  end
end
