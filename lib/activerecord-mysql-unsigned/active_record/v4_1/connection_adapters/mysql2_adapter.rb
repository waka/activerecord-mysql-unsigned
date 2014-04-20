require 'active_record/connection_adapters/mysql2_adapter'

module ActiveRecord
  module ConnectionAdapters
    class Mysql2Adapter < AbstractMysqlAdapter

      class Column < AbstractMysqlAdapter::Column
        attr_reader :unsigned

        def initialize(name, default, sql_type = nil, null = true, collation = nil, strict = false, extra = "")
          if sql_type.present?
            @unsigned = sql_type.include? "unsigned"
          else
            @unsigned = false
          end
          super(name, default, sql_type, null, collation, strict, extra)
        end
      end

    end
  end
end
