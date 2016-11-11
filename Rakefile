#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

# http://erniemiller.org/2014/02/05/7-lines-every-gems-rakefile-should-have/
task :console do
  require 'irb'
  require 'irb/completion'
  require 'tapir/reports'
  ARGV.clear
  IRB.start
end

task :default => :spec
