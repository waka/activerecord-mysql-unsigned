require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter
 
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
        add_column_sql = "ADD #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit], options[:precision], options[:scale], options[:unsigned])}"
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

        change_column_sql = "CHANGE #{quote_column_name(column_name)} #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit], options[:precision], options[:scale], options[:unsigned])}"
        add_column_options!(change_column_sql, options)
        add_column_position!(change_column_sql, options)
        change_column_sql
      end

    end
  end
end
