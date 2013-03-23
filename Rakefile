require 'bundler/setup'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

desc "Run tests"
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w{--colour --format progress}
    t.pattern = 'spec/**/*_spec.rb'
  end
end

task :default => :spec