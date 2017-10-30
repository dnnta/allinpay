module Allinpay
  # 通联支付
  # @attr merchant [String] 通联支付商户号
  # @attr username  [String] 通联支付用户名
  # @attr password  [String] 通联支付密码
  # @attr public_path  [String]  公共证书位置
  # @attr private_path  [String]  私密证书位置
  # @attr private_password [String]  私密证书密码
  # @attr conn [Request] 请求信息


  class Client
    attr_accessor :merchant, :username, :password, :conn

    class << self
      attr_accessor :private_path, :public_path, :private_password
    end

    # 初始化通联支付
    #
    # @param options [Hash] 交易信息
    # @option options [String] :merchant 通联支付商户号
    # @option options [String] :username 通联支付用户名
    # @option options [String] :password 通联支付密码
    # @option options [String] :env 设置环境
    # @option options [String] :public_path 公共证书位置
    # @option options [String] :private_path 私密证书位置
    # @option options [String] :private_password 私密证书密码

    def initialize(options)
      @merchant = options[:merchant]
      @username = options[:username]
      @password = options[:password]
      env = options[:env] || 'development'
      @conn = Allinpay::Service.connection(env, options)
    end

    private

    # 设置基本信息
    #
    # @param code [String] 交易代码
    # @param options [Hash] 其它信息
    #
    # return [Hash] 

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

    # 生成交易序号

    def req_sn
      merchant + timestamps + rand(1000).to_s.ljust(4, '0')
    end

    # 生成时间

    def timestamps
      Time.now.strftime('%Y%m%d%H%M%S')
    end

    # 将结果重新包装
    # @param status [String] 返回状态
    # @param data [String, Hash, Array, nil] 包装数据
    # @param request [Hash] 请求数据 

    def result_wrap(status, data, request = nil)
      return { "status" => status.to_s, "data" => data, "request" => request }
    end
  end
end
