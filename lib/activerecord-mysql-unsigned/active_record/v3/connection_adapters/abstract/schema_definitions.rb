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
      def primary_key(name, type = :primary_key, options = {})
        column(name, type, options.merge(primary_key: true).reverse_merge(unsigned: true))
      end

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
