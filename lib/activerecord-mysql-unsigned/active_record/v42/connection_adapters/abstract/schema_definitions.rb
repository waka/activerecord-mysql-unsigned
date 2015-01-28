require 'active_record/connection_adapters/abstract/schema_definitions'

module ActiveRecord
  module ConnectionAdapters
    class ColumnDefinition
      attr_accessor :unsigned
    end

    class TableDefinition
      def primary_key(name, type = :primary_key, options = {})
        column(name, type, options.merge(primary_key: true).reverse_merge(unsigned: true))
      end

      alias_method :new_column_definition_without_unsigned, :new_column_definition
      def new_column_definition(name, type, options)
        column = new_column_definition_without_unsigned(name, type, options)
        column.unsigned = options[:unsigned]
        column
      end
    end
  end
end
