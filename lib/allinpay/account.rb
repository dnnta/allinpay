module Allinpay
  # 通联支付 账户查询接口
  # 
  # 具体文档请查看 http://113.108.182.3:8282/techsp/helper/interapi/tlt/interapi1.html
  #
  # @todo
  #  * 添加历史余额查询
  #  * 账户提现
  module Account
    extend ActiveSupport::Concern
    included do

      # 账户信息查询    交易代码：300000
      # 查询商户在通联的虚拟账户基本信息
      #
      # @param account_number [String] 账户号码
      #
      # @return [Hash] (see Allinpay::Client#result_wrap)
      
      def account(account_number = nil)
        params = set_infomation('300000', { REQTIME: timestamps, LEVEL: 9 })
        params[:ACQUERYREQ] = { ACCTNO: account_number} if account_number
        res = conn.request(params)
        return result_wrap(:fail, res, params) if res["INFO"]["RET_CODE"] != "0000"
        return result_wrap(:success, res, params)
      end

      # 账户充值接口
      #
      # @param bank_account [String] 银行账户
      # @param amount [Integer] 充值金额
      # @param business_code [String] 业务代码 默认 100005
      # @param options [Hash] 其它
      # @option options [String] :summary 银行交易2
      # @option options [String] :remark 商户交易备注  
      #
      # @return [Hash] (see Allinpay::Client#result_wrap)
      
      def charge(bank_account, amount, business_code = '19900', options = {})
        params = set_infomation('300006', { REQTIME: timestamps, LEVEL: 9 })
        charge_info = { 
          BUSINESS_CODE: business_code,
          BANKACCT: bank_account,
          AMOUNT: amount
        }
        charge_info[:SUMMARY] = options[:summary] if options[:summary]
        charge_info[:REMARK] = options[:remark] if options[:remark]
        params[:CHARGEREQ] = charge_info
        res = conn.request(params)
        return result_wrap(:fail, res, params) if res["INFO"]["RET_CODE"] != "0000"
        return result_wrap(:success, res, params)
      end
    end
  end
end
