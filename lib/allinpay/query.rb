###
# 交易查询接
# 1.支付交易结果查询
#
###


module Allinpay
  module Query
    extend ActiveSupport::Concern
    included do

      # 支付交易结果查询
      #
      # Paramters:
      #
      # sn: 交易序号
      # options:
      
      def query_batch_pay(sn, options = {})
        params = set_infomation('200004')
        tran_body = { MERCHANT_ID: merchant, QUERY_SN: sn }
        rean_body[:TYPE] = options[:type] if options[:type]
        rean_body[:STATUS] = options[:status] if options[:status]
        rean_body[:START_DAY] = options[:start_day] if options[:start_day]
        rean_body[:END_DAY] = options[:end_day] if options[:end_day]
        params[:QTRANSREQ] = tran_body
        res = conn.request(params)
        return result_wrap(:fail, res) if res["INFO"]["RET_CODE"] != "0000"
        return result_wrap(:success, res, params)
      end
    end
  end
end
