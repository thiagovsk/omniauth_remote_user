require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_test'
desc "Run specs."
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test    => :spec

