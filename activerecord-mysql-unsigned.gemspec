# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord-mysql-unsigned/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-mysql-unsigned"
  spec.version       = ActiveRecord::Mysql::Unsigned::VERSION
  spec.authors       = ["yo_waka"]
  spec.email         = ["y.wakahara@gmail.com"]
  spec.description   = %q{Add unsigned option to integer type for ActiveRecord's MySQL2 adapter}
  spec.summary       = %q{Add unsigned option to integer type for ActiveRecord's MySQL2 adapter}
  spec.homepage      = "https://github.com/waka/activerecord-mysql-unsigned"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "database_cleaner"
  spec.add_runtime_dependency "activesupport", ">= 3.2", "< 5.0"
  spec.add_runtime_dependency "activerecord", ">= 3.2", "< 5.0"
  spec.add_runtime_dependency "mysql2"
end
