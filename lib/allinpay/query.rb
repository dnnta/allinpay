###
# 交易查询接
# 1.支付交易结果查询
#
###


module Allinpay
  module Query
    extend ActiveSupport::Concern
    included do

      # 交易结果查询 交易代码：200004
      #
      # @param sn [String] 要查询的交易流水, 若不填时间必填
      # @param options [Hash] 其它信息
      # @option options [String] :type 查询类型, 如果使用0查询，未完成交易将查不到
      # @option options [String] :status 状态,  如果开始时间和结束时间不为空，该字段生效，不可为空
      # @option options [String] :start_day 开始时间, 若不填QUERY_SN则必填
      # @option options [String] :end_day 结束时间, 填了开始时间必填
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
