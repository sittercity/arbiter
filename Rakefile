$:.unshift File.dirname(__FILE__) + '/lib'

load 'lib/tasks/arbiter.rake'

require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new(:spec)
