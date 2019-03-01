require 'allinpay/version'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/array'
require 'active_support/concern'
require 'faraday'

module Allinpay
  autoload :Client, 'allinpay/client'
  autoload :Signature, 'allinpay/signature'
  autoload :Service, 'allinpay/service'
  autoload :Account, 'allinpay/account'
  autoload :Payment, 'allinpay/payment'
  autoload :Query, 'allinpay/query'
  autoload :api_loader, 'allinpay/api_loader'
  autoload :configuration, 'allinpay/configuration'
  
  
  class << self
    def configuration
      yield configure
    end

    def configure
      @config ||= Configuration.new
    end

    def api
      @allinpay ||= ApiLoader.with(configure) 
    end
  end

end

