require 'allinpay/version'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/array'
require 'faraday'

module Allinpay
  # Your code goes here...
  autoload :Client, 'allinpay/client'
  autoload :Signature, 'allinpay/signature'
end
