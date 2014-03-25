require 'active_record/connection_adapters/abstract/schema_dumper'

module ActiveRecord
  module ConnectionAdapters # :nodoc:

    module ColumnDumper

      def prepare_column_options(column, types)
        spec = {}
        #binding.pry if column.name.include?("ip")
        spec[:name]      = column.name.inspect

        # AR has an optimization which handles zero-scale decimals as integers. This
        # code ensures that the dumper still dumps the column as a decimal.
        spec[:type]      = if column.type == :integer && /^(numeric|decimal)/ =~ column.sql_type
                             'decimal'
                           else
                             column.type.to_s
                           end
        spec[:limit]     = column.limit.inspect if column.limit != types[column.type][:limit] && spec[:type] != 'decimal'
        spec[:precision] = column.precision.inspect if column.precision
        spec[:scale]     = column.scale.inspect if column.scale
        spec[:null]      = 'false' unless column.null
        spec[:unsigned]  = 'true' if column.unsigned
        spec[:default]   = default_string(column.default) if column.has_default?
        spec
      end
      # Lists the valid migration options
      def migration_keys
        [:name, :limit, :precision, :unsigned, :scale, :default, :null]
      end

    end

  end
end