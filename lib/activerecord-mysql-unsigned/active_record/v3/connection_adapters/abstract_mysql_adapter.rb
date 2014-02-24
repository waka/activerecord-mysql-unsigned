require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter

      NATIVE_DATABASE_TYPES.merge!(
        primary_key: "int(10) unsigned DEFAULT NULL auto_increment PRIMARY KEY"
      )
 
      # Maps logical Rails types to MySQL-specific data types.
      def type_to_sql(type, limit = nil, precision = nil, scale = nil, unsigned = false, auto_increment = false)
        case type.to_s
        when 'integer'
          case limit
          when 1
            'tinyint' + (unsigned ? ' unsigned' : '') + (auto_increment ? ' AUTO_INCREMENT' : '')
          when 2
            'smallint' + (unsigned ? ' unsigned' : '') + (auto_increment ? ' AUTO_INCREMENT' : '')
          when 3
            'mediumint' + (unsigned ? ' unsigned' : '') + (auto_increment ? ' AUTO_INCREMENT' : '')
          when nil, 4, 11 # compatibility with MySQL default
            if unsigned
              'int(10) unsigned' + (auto_increment ? ' AUTO_INCREMENT' : '')
            else
              'int(10)'
            end
          when 5..8
            'bigint' + (unsigned ? ' unsigned' : '') + (auto_increment ? ' AUTO_INCREMENT' : '')
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

      def add_column_sql(table_name, column_name, type, options = {})
        add_column_sql = "ADD #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit], options[:precision], options[:scale], options[:unsigned], options[:auto_increment])}"
        add_column_options!(add_column_sql, options)
        add_column_position!(add_column_sql, options)
        add_column_sql
      end

      def change_column_sql(table_name, column_name, type, options = {})
        column = column_for(table_name, column_name)

        unless type.to_sym == :primary_key
          unless options_include_default?(options)
            options[:default] = column.default
          end
          unless options.has_key?(:null)
            options[:null] = column.null
          end
        end

        change_column_sql = "CHANGE #{quote_column_name(column_name)} #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit], options[:precision], options[:scale], options[:unsigned], options[:auto_increment])}"
        add_column_options!(change_column_sql, options)
        add_column_position!(change_column_sql, options)
        change_column_sql
      end

    end
  end
end
