require 'allinpay/version'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/array'
require "active_support/core_ext/hash/indifferent_access"
require 'active_support/concern'
require 'faraday'

module Allinpay
  autoload :Client, 'allinpay/client'
  autoload :ApiLoader, 'allinpay/api_loader'
  autoload :Configuration, 'allinpay/configuration'
  
  
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

