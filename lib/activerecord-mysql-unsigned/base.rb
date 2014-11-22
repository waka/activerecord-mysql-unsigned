if ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 1
  require 'activerecord-mysql-unsigned/active_record/v4_1/connection_adapters/abstract/schema_definitions'
  require 'activerecord-mysql-unsigned/active_record/v4_1/connection_adapters/abstract/schema_statements'
  require 'activerecord-mysql-unsigned/active_record/v4_1/connection_adapters/abstract/schema_dumper'
  require 'activerecord-mysql-unsigned/active_record/v4_1/connection_adapters/abstract_mysql_adapter'
elsif ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 0
  require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract/schema_definitions'
  require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract/schema_statements'
  require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract/schema_dumper'
  require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract_adapter'
  require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract_mysql_adapter'
elsif ActiveRecord::VERSION::MAJOR == 3
  require 'activerecord-mysql-unsigned/active_record/v3/connection_adapters/abstract/schema_definitions'
  require 'activerecord-mysql-unsigned/active_record/v3/connection_adapters/abstract/schema_statements'
  require 'activerecord-mysql-unsigned/active_record/v3/connection_adapters/abstract_mysql_adapter'
else
  raise "activerecord-mysql-unsigned supprts ActiveRecord::VERSION::MAJOR >= 3"
end
