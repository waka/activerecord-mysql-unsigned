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
          add_column_options!(change_column_sql, options.merge(column: column))
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
      def type_to_sql(type, limit = nil, precision = nil, scale = nil, unsigned = false)
        case type.to_s
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
        when 'text'
          case limit
          when 0..0xff;               'tinytext'
          when nil, 0x100..0xffff;    'text'
          when 0x10000..0xffffff;     'mediumtext'
          when 0x1000000..0xffffffff; 'longtext'
          else raise(ActiveRecordError, "No text type has character length #{limit}")
          end
        else
          super
        end
      end

    end
  end
end
