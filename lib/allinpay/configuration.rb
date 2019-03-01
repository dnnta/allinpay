module Allinpay
  class Configuration
  # 通联支付
  # @attr merchant [String] 通联支付商户号
  # @attr username  [String] 通联支付用户名
  # @attr password  [String] 通联支付密码
  # @attr public_path  [String]  公共证书位置
  # @attr private_path  [String]  私密证书位置
  # @attr private_password [String]  私密证书密码
  # @attr conn [Request] 请求信息

    attr_accessor :merchant, :username, :password, :env, :private_path,
                  :private_password, :public_path, :ssl
    
    def initialize
      @env = 'development'
      @ssl = false
    end
end