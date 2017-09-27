###
#  交易接口
#  1. 单笔实时支付
#
###


module Allinpay
  module Payment
    extend ActiveSupport::Concern
    included do

      # 通联支付单笔实时支付
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

      # 通联支付批量付款
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
