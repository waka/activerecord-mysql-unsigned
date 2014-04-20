require 'active_record/connection_adapters/abstract/schema_creation'

module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      class SchemaCreation

        def visit_AddColumn(o)
          sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
          sql = "ADD #{quote_column_name(o.name)} #{sql_type}"
          add_column_options!(sql, column_options(o))
        end

      end
    end
  end
end
