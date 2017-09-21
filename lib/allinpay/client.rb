module Allinpay
  class Client
    attr_accessor :merchant, :username, :password, :conn

    class << self
      attr_accessor :private_path, :public_path, :private_password
    end

    def initialize(options)
      @merchant = options[:merchant]
      @username = options[:username]
      @password = options[:password]
      env = options[:env] || 'development'
      @conn = Allinpay::Service.connection(env, options)
    end

    # 通联支付单笔实时支付
    def pay(tran, options = {})
      params = set_infomation('100014').merge({
        TRANS: {
          BUSINESS_CODE: options[:business_code] || '09900', 
          MERCHANT_ID: merchant, 
          SUBMIT_TIME: timestamps,
          E_USER_CODE: 1,
          BANK_CODE: tran[:bank_code],
          ACCOUNT_TYPE: tran[:account_type],
          ACCOUNT_NO:  tran[:account_number],
          ACCOUNT_NAME: tran[:account_name],
          ACCOUNT_PROP: tran[:account_prop]
        }
      })
      res = conn.request(params)
      return result_wrap(:success, res)
    end

    # 通联支付批量付款
    def batch_pay(trans, options = {})
      details = []
      index = 1
      params = set_infomation('100002', {LEVEL: 9})
      trans_sum = {
        BUSINESS_CODE: options[:business_code] || '09900', 
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
      params.merge({BODY: { TRANS_SUM: trans_sum, TRANS_DETAILS: details }})
      res = conn.request(params)
      res_info = res["INFO"]
      return result_wrap(:fail, res) if res_info["RET_CODE"] != "0000"
      query_batch_pay(res_info["REQ_SN"])
    end

    # 通联支付交易结果查询
    def query_batch_pay(sn)
      tran_body = { MERCHANT_ID: merchant, QUERY_SN: sn, type: '1' }
      params = set_infomation('200004').merge({ QTRANSREQ: tran_body })
      res = conn.request(params)
      return result_wrap(:fail, res) if res["INFO"]["RET_CODE"] != "0000"
      return result_wrap(:success, res)
    end

    private

    def set_infomation(code, options = {})
      info = {
        TRX_CODE: code,
        VERSION: '03', 
        DATA_TYPE: '2',
        USER_NAME: username, 
        USER_PASS: password, 
        REQ_SN: req_sn
      }.merge(options)
      return { INFO: info }
    end

    def req_sn
      merchant + timestamps + rand(1000).to_s.ljust(4, '0')
    end

    def timestamps
      Time.now.strftime('%Y%m%d%H%M%S')
    end

    def result_wrap(status, data)
      return {"status" => status, "data" => data}
    end
  end
end
