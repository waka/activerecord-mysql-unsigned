require 'active_record/connection_adapters/abstract/schema_definitions'

module ActiveRecord
  module ConnectionAdapters
    class ColumnDefinition
      attr_accessor :unsigned
    end

    class TableDefinition
      alias_method :new_column_definition_without_unsigned, :new_column_definition
      def new_column_definition(name, type, options)
        column = new_column_definition_without_unsigned(name, type, options)
        column.unsigned = options[:unsigned]
        column
      end
    end
  end
end
