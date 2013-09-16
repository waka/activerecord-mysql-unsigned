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

      def auto_increment=(value)
        @auto_increment = value
      end

      def auto_increment
        @auto_increment
      end

      def sql_type
        base.type_to_sql(type.to_sym, limit, precision, scale, unsigned, auto_increment) rescue type
      end
    end

    class TableDefinition

      def column(name, type, options = {})
        name = name.to_s
        type = type.to_sym

        column = self[name] || new_column_definition(@base, name, type)

        limit = options.fetch(:limit) do
          native[type][:limit] if native[type].is_a?(Hash)
        end

        column.limit          = limit
        column.unsigned       = options[:unsigned]
        column.auto_increment = options[:auto_increment]
        column.precision      = options[:precision]
        column.scale          = options[:scale]
        column.default        = options[:default]
        column.null           = options[:null]
        self
      end

    end
  end
end
