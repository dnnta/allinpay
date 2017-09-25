module Allinpay
  class Client
    attr_accessor :merchant, :username, :password, :conn

    class << self
      attr_accessor :private_path, :public_path, :private_password
    end

    def initialize(options)
      @merchant = options[:merchant]
      @username = options[:username]
      @password = options[:password]
      env = options[:env] || 'development'
      @conn = Allinpay::Service.connection(env, options)
    end

    private

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

    def req_sn
      merchant + timestamps + rand(1000).to_s.ljust(4, '0')
    end

    def timestamps
      Time.now.strftime('%Y%m%d%H%M%S')
    end

    def result_wrap(status, data)
      return {"status" => status, "data" => data}
    end
  end
end
