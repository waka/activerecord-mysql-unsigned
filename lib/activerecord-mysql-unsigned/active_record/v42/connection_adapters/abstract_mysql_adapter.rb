require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter
 
      class ChangeColumnDefinition < Struct.new(:column, :type, :options) #:nodoc:
      end

      class SchemaCreation < AbstractAdapter::SchemaCreation
        def visit_AddColumn(o)
          sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
          add_column_sql = "ADD #{quote_column_name(o.name)} #{sql_type}"
          add_column_options!(add_column_sql, column_options(o)) unless o.type.to_sym == :primary_key
          add_column_position!(add_column_sql, column_options(o))

          add_column_sql
        end

        def visit_ChangeColumnDefinition(o)
          column = o.column
          options = o.options
          sql_type = type_to_sql(o.type, options[:limit], options[:precision], options[:scale], options[:unsigned])
          change_column_sql = "CHANGE #{quote_column_name(column.name)} #{quote_column_name(options[:name])} #{sql_type}"
          add_column_options!(change_column_sql, options.merge(column: column)) unless o.type.to_sym == :primary_key
          add_column_position!(change_column_sql, options)

          change_column_sql
        end

        def visit_ColumnDefinition(o)
          sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
          column_sql = "#{quote_column_name(o.name)} #{sql_type}"
          add_column_options!(column_sql, column_options(o)) unless o.type.to_sym == :primary_key

          column_sql
        end

        def column_options(o)
          column_options = super
          column_options[:first] = o.first
          column_options[:after] = o.after
          column_options
        end

        def add_column_position!(sql, options)
          if options[:first]
            sql << " FIRST"
          elsif options[:after]
            sql << " AFTER #{quote_column_name(options[:after])}"
          end
        end

        def type_to_sql(type, limit, precision, scale, unsigned = false)
          @conn.type_to_sql type.to_sym, limit, precision, scale, unsigned
        end
      end

      class Column < ConnectionAdapters::Column # :nodoc:
        def unsigned?
          sql_type =~ /unsigned/i
        end
      end

      def prepare_column_options(column, types) # :nodoc:
        spec = super
        spec[:unsigned] = 'true' if column.unsigned?
        spec
      end

      def migration_keys
        super + [:unsigned]
      end

      alias_method :type_to_sql_without_unsigned, :type_to_sql
      def type_to_sql(type, limit = nil, precision = nil, scale = nil, unsigned = false)
        case type.to_s
        when 'integer'
          case limit
          when nil, 4, 11; 'int'  # compatibility with MySQL default
          else
            type_to_sql_without_unsigned(type, limit, precision, scale)
          end.tap do |sql_type|
            sql_type << ' unsigned' if unsigned
          end
        when 'float', 'decimal'
          type_to_sql_without_unsigned(type, limit, precision, scale).tap do |sql_type|
            sql_type << ' unsigned' if unsigned
          end
        when 'primary_key'
          "#{type_to_sql(:integer, limit, precision, scale, unsigned)} auto_increment PRIMARY KEY"
        else
          type_to_sql_without_unsigned(type, limit, precision, scale)
        end
      end

      def add_column_sql(table_name, column_name, type, options = {})
        td = create_table_definition table_name, options[:temporary], options[:options]
        cd = td.new_column_definition(column_name, type, options)
        schema_creation.visit_AddColumn cd
      end

      def change_column_sql(table_name, column_name, type, options = {})
        column = column_for(table_name, column_name)

        unless options_include_default?(options)
          options[:default] = column.default
        end

        unless options.has_key?(:null)
          options[:null] = column.null
        end

        options[:name] = column.name
        schema_creation.visit_ChangeColumnDefinition ChangeColumnDefinition.new column, type, options
      end

    end
  end
end
