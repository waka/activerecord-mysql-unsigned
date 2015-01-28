if ActiveRecord::VERSION::MAJOR == 4
  if ActiveRecord::VERSION::MINOR >= 2
    require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract/schema_definitions'
    require 'activerecord-mysql-unsigned/active_record/v42/connection_adapters/abstract_mysql_adapter'
  else
    require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract/schema_definitions'
    require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract_mysql_adapter'
  end
elsif ActiveRecord::VERSION::MAJOR == 3
  require 'activerecord-mysql-unsigned/active_record/v3/connection_adapters/abstract/schema_definitions'
  require 'activerecord-mysql-unsigned/active_record/v3/connection_adapters/abstract/schema_creation'
  require 'activerecord-mysql-unsigned/active_record/v3/connection_adapters/abstract_mysql_adapter'
else
  raise "activerecord-mysql-unsigned supprts ActiveRecord::VERSION::MAJOR >= 3"
end
