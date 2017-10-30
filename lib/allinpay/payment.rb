module Allinpay
  # 通联支付 支付接口
  #
  # 具体文档请查看 http://113.108.182.3:8282/techsp/helper/interapi/tlt/interapi0.html
  module Payment
    extend ActiveSupport::Concern
    included do

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
          ACCOUNT_PROP: tran[:account_prop]
        }
        params[:TRANS] = tran_body
        res = conn.request(params)
        return result_wrap(:fail, res, params) if res_info["RET_CODE"] != "0000"
        return result_wrap(:success, res, params)
      end

      # 批量代付    交易代码：100002
      # 
      # @param trans [Array<Hash>] 交易信息
      # @option trans [String] :bank_code 银行代码，存折必须填写
      # @option trans [String] :account_number 银行卡或存折号码
      # @option trans [String] :account_name 银行卡或存折上的所有人姓名
      # @option trans [String] :account_prop 账号属性 0私人，1公司。不填时，默认为私人0
      # @param options [Hash] 其它信息 具体参考http://113.108.182.3:8282/techsp/helper/filedetail/tlt/filedetail131.html
      #
      # @return [Hash] (see Allinpay::Client#result_wrap)
      
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
    end
  end
end
