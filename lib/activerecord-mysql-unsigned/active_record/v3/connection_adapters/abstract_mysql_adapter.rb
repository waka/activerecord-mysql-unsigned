require 'activerecord-mysql-unsigned/active_record/v4/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter

      class TableDefinition
        def initialize(base)
          @base = base
        end

        def new_column_definition(name, type, options) # :nodoc:
          column = create_column_definition name, type
          limit = options.fetch(:limit) do
            native[type][:limit] if native[type].is_a?(Hash)
          end

          column.limit       = limit
          column.precision   = options[:precision]
          column.scale       = options[:scale]
          column.unsigned    = options[:unsigned]
          column.default     = options[:default]
          column.null        = options[:null]
          column.first       = options[:first]
          column.after       = options[:after]
          column
        end

        private

        def create_column_definition(name, type)
          ColumnDefinition.new @base, name, type
        end

        def native
          @base.native_database_types
        end
      end

      def schema_creation
        SchemaCreation.new self
      end

      def create_table_definition(name, temporary, options)
        TableDefinition.new self
      end

    end
  end
end
