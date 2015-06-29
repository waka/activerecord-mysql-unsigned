require 'active_record'

config = {
  adapter: 'mysql2',
  encoding: 'utf8',
  database: 'activerecord_mysql_unsigned'
}

ActiveRecord::Base.establish_connection(config.merge(database: 'mysql'))
ActiveRecord::Base.connection.drop_database(config[:database]) rescue nil
ActiveRecord::Base.connection.create_database(config[:database])
ActiveRecord::Base.establish_connection(config)
#ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Migration.verbose = true

# create goods table
class CreateGoodsTable < ActiveRecord::Migration
  def self.change
    create_table :goods, force: true, limit: 8 do |t|
      t.string  :name, null: false
      t.boolean :deleted, default: false
    end
  end
end
CreateGoodsTable.change

# create users table
class CreateUsersTable < ActiveRecord::Migration
  def self.change
    create_table :users, force: true, id: false do |t|
      t.column  :id, "int(10) NOT NULL PRIMARY KEY AUTO_INCREMENT" # AR's default primary_key
      t.string  :name, null: false
      t.integer :signed_int
      t.integer :unsigned_int, unsigned: true
      t.integer :will_unsigned_int, unsigned: false
      t.integer :will_signed_int, unsigned: true
      t.integer :will_bigint
      t.decimal :signed_decimal, null: false, default: 0, precision: 15, scale: 2
      t.decimal :unsigned_decimal, null: false, default: 0, unsigned: true, precision: 15, scale: 2
      t.integer :will_unsigned_bigint
    end
  end
end
CreateUsersTable.change

class ChangePrimaryKeyToGoodsTable < ActiveRecord::Migration
  def self.change
    change_column :goods, :id, :integer, limit: 8, unsigned: true, null: false, auto_increment: true
  end
end

class ChangeColumnToUsersTable < ActiveRecord::Migration
  def self.change
    change_column :users, :id,                :integer, limit: 8, unsigned: true, null: false, auto_increment: true
    change_column :users, :will_unsigned_int, :integer, unsigned: true
    change_column :users, :will_signed_int,   :integer, unsigned: false
    change_column :users, :will_bigint,       :integer, limit: 8
    change_column :users, :will_unsigned_bigint, :bigint, unsigned: true
  end
end

class AddColumnToUsersTable < ActiveRecord::Migration
  def self.change
    add_column    :users, :added_unsigned_int, :integer, unsigned: true
  end
end

class AddColumnAfterToGoodsTable < ActiveRecord::Migration
  def self.change
    add_column    :goods, :added_after_name, :integer, unsigned: true, after: :name
  end
end
