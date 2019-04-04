require "active_support/core_ext/hash/indifferent_access"

module Allinpay
  module Helper
    module Payment
      def default_pay_options(code)
        info = {
          TRX_CODE: code,
          VERSION: '04', 
          DATA_TYPE: '2',
          LEVEL: '9',
          MERCHANT_ID: configurate.merchant, 
          USER_NAME: configurate.username, 
          USER_PASS: configurate.password, 
          REQ_SN: req_sn
        }

        {INFO: info}
      end

      def set_pay_params(tran = {})
        tran = handle_params(tran)
        params = default_pay_options('100014')
        tran_body = {
          BUSINESS_CODE: tran[:business_code] || '09900', 
          MERCHANT_ID: configurate.merchant, 
          SUBMIT_TIME: timestamps,
          E_USER_CODE: '1',
          BANK_CODE: tran[:bank_code],
          ACCOUNT_TYPE: tran[:account_type],
          ACCOUNT_NO:  tran[:account_number],
          ACCOUNT_NAME: tran[:account_name],
          ACCOUNT_PROP: tran[:account_prop],
          AMOUNT: change_amount(tran[:amount])
        }
        params[:TRANS] = tran_body
        params
      end

      def set_batch_pay_params(trans = [], options={})
        params = default_pay_options('100002')
        details, index = [], 1

        trans_sum = {
          BUSINESS_CODE: '09900', 
          MERCHANT_ID: configurate.merchant, 
          SUBMIT_TIME: timestamps,
          TOTAL_ITEM: 0
        }
        
        trans_sum[:TOTAL_SUM] = trans.inject(0) do |sum, item|
          sn = index.to_s.rjust(4, '0')
          item = handle_params(item)
          amount = change_amount(item[:amount])

          details << {
            SN: item[:number] || sn,
            E_USER_CODE: 1,
            BANK_CODE: item[:bank_code],
            ACCOUNT_TYPE: item[:account_type],
            ACCOUNT_NO:  item[:account_number],
            ACCOUNT_NAME: item[:account_name],
            ACCOUNT_PROP: item[:account_prop],
            AMOUNT: amount
          }
          trans_sum[:TOTAL_ITEM] += 1
          amount + sum
        end

        params[:BODY] = { TRANS_SUM: trans_sum, TRANS_DETAILS: details }
        params
      end

      def set_account_params(tran = {})
        tran = handle_params(tran)
        params = default_pay_options('300000')
        params[:ACQUERYREQ] = { ACCTNO: tran[:account_no]}
        params
      end

      def set_balance_params(tran={})
        tran = handle_params(tran)
        params = default_pay_options('300001')
        params[:AHQUERYREQ] = { ACCTNO: tran[:account_no] || configurate.merchant,
                                STARTDAY: tran[:start_day], ENDDAY: tran[:end_day] }
        params
      end

      def set_query_params(req_sn)
        params = default_pay_options('200004')
        params[:QTRANSREQ] = { MERCHANT_ID: configurate.merchant, QUERY_SN: req_sn }
        params
      end

      def set_balance_account_params(tran)
        tran = handle_params(tran)
        params = default_pay_options('200002')
        params[:QTRANSREQ] = { 
          MERCHANT_ID: configurate.merchant, 
          STATUS: tran[:status] || 2,
          TYPE: tran[:type] || 1,
          CONTFEE: tran[:contfee] || 0,
          START_DAY: tran[:start_day],
          END_DAY: tran[:end_day],
          SETTACCT: tran[:settacct]
        }
        params
      end


      private

      # 生成交易序号
      def req_sn
        configurate.merchant + timestamps + configurate.platform.to_s + rand(1000).to_s.ljust(4, '0')
      end

      # 生成时间
      def timestamps
        Time.now.strftime('%Y%m%d%H%M%S')
      end

      # 元转化成分
      def change_amount(amount)
        amount = amount.to_d * 100
        amount.to_i
      end

      def handle_params options
        ActiveSupport::HashWithIndifferentAccess.new(options)
      end
    end
  end
end
