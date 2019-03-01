module Allinpay
  module Api
    # 单笔实时付款    交易代码：100014
    #
    # @param tran [Hash] 交易信息
    # @option tran [String] :bank_code 银行代码，存折必须填写
    # @option tran [String] :account_number 银行卡或存折号码
    # @option tran [String] :account_name 银行卡或存折上的所有人姓名
    # @option tran [String] :account_prop 账号属性 0私人，1公司。不填时，默认为私人0
    # @param options [Hash] 其它信息 具体参考http://113.108.182.3:8282/techsp/helper/filedetail/tlt/filedetail743.html
    #
    # @return [Hash] (see Allinpay::Client#result_wrap)

      
    def pay(tran, options = {})
      params = set_infomation('100014')
      tran_body = {
        BUSINESS_CODE: options[:business_code] || '09900', 
        MERCHANT_ID: merchant, 
        SUBMIT_TIME: timestamps,
        E_USER_CODE: 1,
        BANK_CODE: tran[:bank_code],
        ACCOUNT_TYPE: tran[:account_type],
        ACCOUNT_NO:  tran[:account_number],
        ACCOUNT_NAME: tran[:account_name],
        ACCOUNT_PROP: tran[:account_prop],
        AMOUNT: tran[:amount]
      }
      params[:TRANS] = tran_body
      res = conn.request(params)
      res_info = res["INFO"]
      return result_wrap(:fail, res, params) if res_info["RET_CODE"] != "0000"
      return result_wrap(:success, res, params)
    end

    def batch_pay(trans, options = {})
        params = set_infomation('100002', {LEVEL: 9})
        details = []
        index = 1
        trans_sum = {
          BUSINESS_CODE: options[:business_code] || '09900', 
          MERCHANT_ID: merchant, 
          SUBMIT_TIME: timestamps
        }
        trans_sum[:TOTAL_SUM] = trans.inject(0) do |sum, item|
          sn = index.to_s.rjust(4, '0')
          amount =  (item[:amount].to_f * 100).to_i
          details << {
            SN: item[:number] || sn,
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
        params[:BODY] = { TRANS_SUM: trans_sum, TRANS_DETAILS: details }
        res = conn.request(params)
        res_info = res["INFO"]
        return result_wrap(:fail, res, params) if res_info["RET_CODE"] != "0000"
        return result_wrap(:success, res, params)
      end

    def query(options)
      params = set_infomation('200004')
      tran_body = { MERCHANT_ID: merchant, QUERY_SN: sn }
      tran_body[:TYPE] = options[:type] if options[:type]
      tran_body[:STATUS] = options[:status] if options[:status]
      tran_body[:START_DAY] = options[:start_day] if options[:start_day]
      tran_body[:END_DAY] = options[:end_day] if options[:end_day]
      params[:QTRANSREQ] = tran_body
      res = conn.request(params)
      return result_wrap(:fail, res) if res["INFO"]["RET_CODE"] != "0000"
      return result_wrap(:success, res, params)
    end

    def account
      params = set_infomation('300000', { REQTIME: timestamps, LEVEL: 9 })
      params[:ACQUERYREQ] = { ACCTNO: account_number} if account_number
      res = conn.request(params)
      return result_wrap(:fail, res, params) if res["INFO"]["RET_CODE"] != "0000"
      return result_wrap(:success, res, params)
    end

    def charge
    end
  end
end