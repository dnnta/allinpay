module Allinpay
  module Helper
    module Common
      def request_url(env)
        if production?
          %q(https://test.allinpaygd.com/aipg/ProcessServlet) 
        else
          %q(https://test.allinpaygd.com/aipg/ProcessServlet)
        end
      end

      def parse_xml(data, indent = 0)
        data_xml = data.to_xml(root: 'AIPG', skip_types: true, dasherize: false, indent: indent).sub('UTF-8', 'GBK')
        data_xml.encode! 'gbk','utf-8'
        data_xml
      end

      def result_wrap
      end

      def set_default_pay_options(options={})
        info = {
          TRX_CODE: code,
          VERSION: '03', 
          DATA_TYPE: '2',
          USER_NAME: username, 
          USER_PASS: password, 
          REQ_SN: req_sn
        }.merge(options)
      end

      def ssl_options
        {verify: true} if configture.ssl
      end

      private

      def production?
        env.to_s == 'production'
      end

      # 生成交易序号
      def req_sn
        merchant + timestamps + rand(1000).to_s.ljust(4, '0')
      end

      # 生成时间
      def timestamps
        Time.now.strftime('%Y%m%d%H%M%S')
      end

    end
  end
end
