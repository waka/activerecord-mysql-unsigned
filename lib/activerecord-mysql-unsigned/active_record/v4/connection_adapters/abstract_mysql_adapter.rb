require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter
 
      class ChangeColumnDefinition < Struct.new(:column, :type, :options) #:nodoc:
      end

      class SchemaCreation < AbstractAdapter::SchemaCreation
        def visit_AddColumn(o)
          sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
          sql = "ADD #{quote_column_name(o.name)} #{sql_type}"
          add_column_options!(sql, column_options(o)) unless o.type.to_sym == :primary_key
          add_column_position!(sql, column_options(o))
        end

        def visit_ChangeColumnDefinition(o)
          column = o.column
          options = o.options
          sql_type = type_to_sql(o.type, options[:limit], options[:precision], options[:scale], options[:unsigned])
          change_column_sql = "CHANGE #{quote_column_name(column.name)} #{quote_column_name(options[:name])} #{sql_type}"
          add_column_options!(change_column_sql, options.merge(column: column)) unless o.type.to_sym == :primary_key
          add_column_position!(change_column_sql, options)
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

      NATIVE_DATABASE_TYPES.merge!(
        :primary_key => "int(10) unsigned DEFAULT NULL auto_increment PRIMARY KEY"
      )

      # Maps logical Rails types to MySQL-specific data types.
      def type_to_sql(type, limit = nil, precision = nil, scale = nil, unsigned = false)
        # return earlier, only need overwrite method when unsigned option == true
        return super unless unsigned

        case type.to_s
        when 'decimal'
          # copy from rails core
          # https://github.com/rails/rails/blob/600aaf4234c80064201ee34ddabed216b91559db/activerecord/lib/active_record/connection_adapters/abstract/schema_statements.rb
          native = native_database_types[type.to_sym]
          column_type_sql = (native.is_a?(Hash) ? native[:name] : native).dup

          scale ||= native[:scale]

          if precision ||= native[:precision]
            if scale
              column_type_sql << "(#{precision},#{scale}) unsigned"
            else
              column_type_sql << "(#{precision}) unsigned"
            end
          elsif scale
            raise ArgumentError, "Error adding decimal column: precision cannot be empty if scale is specified"
          end
          
        when 'binary'
          case limit
          when 0..0xfff;           "varbinary(#{limit})"
          when nil;                "blob"
          when 0x1000..0xffffffff; "blob(#{limit})"
          else raise(ActiveRecordError, "No binary type has character length #{limit}")
          end
        when 'integer'
          case limit
          when 1
            'tinyint unsigned'
          when 2
            'smallint unsigned'
          when 3
            'mediumint unsigned'
          when nil, 4, 11 # compatibility with MySQL default
            'int(10) unsigned'
          when 5..8
            'bigint unsigned'
          else raise(ActiveRecordError, "No integer type has byte size #{limit}")
          end
        else
          super
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
