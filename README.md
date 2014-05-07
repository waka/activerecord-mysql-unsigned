# Activerecord::Mysql::Unsigned [![Build Status](https://travis-ci.org/waka/activerecord-mysql-unsigned.png?branch=master)](https://travis-ci.org/waka/activerecord-mysql-unsigned)

Add unsigned option to integer type for ActiveRecord's MySQL2 adapter.

## Support version

```
4.2 > ActiveRecord::VERSION >= 3.2
```

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-mysql-unsigned'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-mysql-unsigned

## Usage

In your migrations you can define integer fields such as:

```
class CreateUsersTable < ActiveRecord::Migration
  def self.change
    create_table :users, force: true do |t|
      t.string  :name, null: false
      t.integer :age,  null: false, unsigned: true
    end
  end
end
```

You can redefine in the existing fields.

```
class ChangeColumnToUsersTable < ActiveRecord::Migration
  def self.change
    change_column :users, :age, :integer, null: false, unsigned: false
  end
end
```

And you can also redefine in the primary key.

```
class ChangeColumnToUsersTable < ActiveRecord::Migration
  def self.change
    change_column :users, :id, :integer, null: false, auto_increment: true, unsigned: true
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
