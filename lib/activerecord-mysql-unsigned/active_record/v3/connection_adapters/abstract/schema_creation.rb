module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      class SchemaCreation # :nodoc:
        def initialize(conn)
          @conn = conn
        end

        private

        def column_options(o)
          column_options = {}
          column_options[:null] = o.null unless o.null.nil?
          column_options[:default] = o.default unless o.default.nil?
          column_options[:column] = o
          column_options[:first] = o.first
          column_options[:after] = o.after
          column_options
        end

        def quote_column_name(name)
          @conn.quote_column_name name
        end

        def add_column_options!(sql, options)
          sql << " DEFAULT #{quote_value(options[:default], options[:column])}" if options_include_default?(options)
          # must explicitly check for :null to allow change_column to work on migrations
          if options[:null] == false
            sql << " NOT NULL"
          end
          if options[:auto_increment] == true
            sql << " AUTO_INCREMENT"
          end
          sql
        end

        def quote_value(value, column)
          @conn.quote(value, column)
        end

        def options_include_default?(options)
          options.include?(:default) && !(options[:null] == false && options[:default].nil?)
        end
      end
    end
  end
end
