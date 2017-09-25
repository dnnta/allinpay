###
# 交易查询接口
#
###


module Allinpay
  module Query
    extend ActiveSupport::Concern
    included do
      # 通联支付交易结果查询
      def query_batch_pay(sn)
        params = set_infomation('200004')
        tran_body = { MERCHANT_ID: merchant, QUERY_SN: sn, type: '1' }
        params[:QTRANSREQ] = tran_body
        res = conn.request(params)
        return result_wrap(:fail, res) if res["INFO"]["RET_CODE"] != "0000"
        return result_wrap(:success, res)
      end
    end
  end
end
