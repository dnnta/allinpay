require 'allinpay/helper/payment'
module Allinpay
  module Api
    include Helper::Payment
    # 单笔实时付款    交易代码：100014
    # @param options [Hash] 交易信息
    # @option options [String] :bank_code 银行代码，存折必须填写
    # @option options [String] :account_number 银行卡或存折号码
    # @option options [String] :account_name 银行卡或存折上的所有人姓名
    # @option options [String] :account_prop 账号属性 0私人，1公司。不填时，默认为私人0
    # @param options [Hash] 其它信息 具体参考http://113.108.182.3:8282/techsp/helper/filedetail/tlt/filedetail743.html
    #
    # @return [Hash] (see Allinpay::Client#result_wrap)

      
    def pay(options = {})
      params = set_pay_params(options)
      request(params)
    end

    def batch_pay(options=[], args={})
      params = set_batch_pay_params(options, args)
      request(params)
    end

    # 查询交易 req_sn 交易流水号
    def query(req_sn)
      params = set_query_params(req_sn)
      request(params)
    end

    def account(options={})
      params = set_account_params(options)
      request(params)
    end

    def balance(options={})
      params = set_balance_params options
      request(params)
    end

    # 对账
    # @option options [String] :status 交易易状态条件, 0成功,1失败, 2全部
    # @option options [String] :type 查询类型 0按完成⽇日期 1按提交⽇日期
    # @option options [String] :contfee 是否包含手续费 0不包含 1包含
    # @option options [String] :start_day 开始⽇
    # @option options [String] :end_day 结束⽇
    # @option options [String] :settacct 结算账号

    def balance_account(options={})
      params = set_balance_account_params options
      request(params)
    end

    def charge
    end
  end
end