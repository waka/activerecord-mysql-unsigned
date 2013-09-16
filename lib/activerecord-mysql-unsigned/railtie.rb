module ActiveRecord
  module Mysql
    module Unsigned
      class Railtie < Rails::Railtie
        initializer 'activerecord-mysql-unsigned' do
          ActiveSupport.on_load :active_record do
            require 'activerecord-mysql-unsigned/base'
          end
        end
      end
    end
  end
end
