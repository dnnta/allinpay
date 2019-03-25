module Allinpay
	module Helper
		module Service
			def parse_xml(data, indent = 0)
        data_xml = data.to_xml(root: 'AIPG', skip_types: true, dasherize: false, indent: indent).sub('UTF-8', 'GBK')
        @request_xml = data_xml.clone
        data_xml.encode! 'gbk','utf-8'
        data_xml
      end

      def result_wrap
        result_xml = Hash.from_xml(response_xml)
        res = result_xml['AIPG']
        res_info = res['INFO']
        response_xml.encode! 'utf-8','gbk'
        status =  res_info["RET_CODE"].to_s.in?(["0000", "4000" ]) ? 'success' : 'fail'

      	{ 
          "status" => status, 
          "data" => {
            'result' => res,
            'request_xml' => request_xml,
            'response_xml' => response_xml,
          },
        }
      end

      def request_url
        if production?
          %q(https://tlt.allinpay.com/aipg/ProcessServlet)
        else
          %q(https://test.allinpaygd.com/aipg/ProcessServlet) 
        end
      end

      def ssl_options
        {verify: production?}
      end

      private

      def production?
        configurate.env.to_s == 'production'
      end

		end
	end
end
