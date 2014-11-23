require 'active_record/connection_adapters/abstract/schema_definitions'

module ActiveRecord
  module ConnectionAdapters
    class ColumnDefinition
      attr_accessor :unsigned, :first, :after

      def sql_type
        base.type_to_sql(type.to_sym, limit, precision, scale, unsigned) rescue type
      end
    end

    class TableDefinition
      alias_method :column_without_unsigned, :column
      def column(name, type, options = {})
        column_without_unsigned(name, type, options)
        column = self[name]
        column.unsigned = options[:unsigned]
        self
      end
    end
  end
end
