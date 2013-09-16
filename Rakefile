require "bundler/gem_tasks"

# Travis CI use RSpec as default task
task :default => [:spec]
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
  end
rescue LoadError => e
end
