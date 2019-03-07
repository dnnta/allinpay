module Allinpay
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      desc 'Generate allinpay configs'
      source_root File.expand_path('../templates', __FILE__)

      def copy_file
        template 'allinpay.rb', 'config/initializers/allinpay.rb'
      end
    end
  end
end