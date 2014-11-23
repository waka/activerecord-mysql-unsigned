require 'forwardable'
require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter

      class SchemaCreation < AbstractAdapter::SchemaCreation
        extend Forwardable
        def visit_AddColumn(o)
          sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
          sql = "ADD #{quote_column_name(o.name)} #{sql_type}"
          add_column_position!(
            add_column_options!(sql, column_options(o)),
            column_options(o)
          )
        end

        def visit_ChangeColumnDefinition(o)
          column = o.column
          options = o.options
          sql_type = type_to_sql(o.type, options[:limit], options[:precision], options[:scale], options[:unsigned])
          change_column_sql = "CHANGE #{quote_column_name(column.name)} #{quote_column_name(options[:name])} #{sql_type}"
          add_column_options!(change_column_sql, options.merge(:column => column))
          add_column_position!(change_column_sql, options)
        end

        def visit_ColumnDefinition(o)
          sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
          column_sql = "#{quote_column_name(o.name)} #{sql_type}"
          add_column_options!(column_sql, column_options(o)) unless o.primary_key?
          column_sql
        end

        def_delegator :@conn, :type_to_sql, :type_to_sql
      end

      NATIVE_DATABASE_TYPES.merge!(
        :primary_key => "int(10) unsigned DEFAULT NULL auto_increment PRIMARY KEY"
      )

      # Maps logical Rails types to MySQL-specific data types.
      def type_to_sql_with_unsigned(type, limit = nil, precision = nil, scale = nil, unsigned = false)
        # return earlier, only need overwrite method when unsigned option == true
        return type_to_sql_without_unsigned(type, limit, precision, scale) unless unsigned


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
            'tinyint' + (unsigned ? ' unsigned' : '')
          when 2
            'smallint' + (unsigned ? ' unsigned' : '')
          when 3
            'mediumint' + (unsigned ? ' unsigned' : '')
          when nil, 4, 11 # compatibility with MySQL default
            if unsigned
              'int(10) unsigned'
            else
              'int(10)'
            end
          when 5..8
            'bigint' + (unsigned ? ' unsigned' : '')
          else raise(ActiveRecordError, "No integer type has byte size #{limit}")
          end
        else
          type_to_sql_without_unsigned(type, limit, precision, scale)
        end
      end
      alias_method_chain :type_to_sql, :unsigned

    end
  end
end
