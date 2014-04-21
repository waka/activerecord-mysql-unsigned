require 'active_record/connection_adapters/abstract/schema_definitions'

module ActiveRecord
  module ConnectionAdapters
    class ColumnDefinition

      def unsigned=(value)
        @unsigned = value
      end

      def unsigned
        @unsigned
      end

    end

    class TableDefinition

      def new_column_definition(name, type, options)
        column = create_column_definition name, type
        limit = options.fetch(:limit) do
          native[type][:limit] if native[type].is_a?(Hash)
        end

        column.limit       = limit
        column.array       = options[:array] if column.respond_to?(:array)
        column.precision   = options[:precision]
        column.scale       = options[:scale]
        column.unsigned    = options[:unsigned]
        column.default     = options[:default]
        column.null        = options[:null]
        column.first       = options[:first]
        column.after       = options[:after]
        column.primary_key = type == :primary_key || options[:primary_key]
        column
      end

    end
  end
end
