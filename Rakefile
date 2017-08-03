require 'rspec/core/rake_task'
require "bundler/gem_tasks"


namespace 'report_builder' do

  desc 'Test the project'
  RSpec::Core::RakeTask.new(:test_everything) do |t, args|
    t.rspec_opts = '--pattern testing/rspec/spec/**/*_spec.rb'
  end

end

task :default => 'report_builder:test_everything'
