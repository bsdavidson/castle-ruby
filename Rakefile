require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError => e
  STDERR.puts "Error importing RSpec: #{e}"
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError => e
  STDERR.puts "Error importing RuboCop: #{e}"
end

task default: [:spec, :rubocop]
