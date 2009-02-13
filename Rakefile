#!/usr/bin/env ruby
require "fileutils"
require 'rubygems'
gem 'rspec'
gem 'rspec-rails'

PROJECT_NAME = 'redmine_custom_email'
REDMINE_PROJECT_NAME = 'none'

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

# Modifided from the RSpec on Rails plugins
PLUGIN_ROOT = File.expand_path(File.dirname(__FILE__))
REDMINE_ROOT = File.expand_path(File.dirname(__FILE__) + '/../../../')
REDMINE_APP = File.expand_path(File.dirname(__FILE__) + '/../../../app')
REDMINE_LIB = File.expand_path(File.dirname(__FILE__) + '/../../../lib')

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'spec/rake/spectask'

$:.unshift(REDMINE_ROOT + '/vendor/plugins/cucumber/lib')
require 'cucumber/rake/task'

CLEAN.include('**/semantic.cache', "**/#{PROJECT_NAME}.zip", "**/#{PROJECT_NAME}.tar.gz")

# No Database needed
spec_prereq = :noop
task :noop do
end

task :default => [:spec, :features]
task :stats => "spec:statsetup"

desc "Run all specs in spec directory (excluding plugin specs)"
Spec::Rake::SpecTask.new(:spec => spec_prereq) do |t|
  t.spec_opts = ['--options', "\"#{PLUGIN_ROOT}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs in spec directory with RCov (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{PLUGIN_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts << ["--rails", "--sort=coverage", "--exclude '/var/lib/gems,spec,#{REDMINE_APP},#{REDMINE_LIB}'"]
  end
  
  desc "Print Specdoc for all specs (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  desc "Print Specdoc for all specs as HTML (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:htmldoc) do |t|
    t.spec_opts = ["--format", "html:doc/rspec_report.html", "--loadby", "mtime"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  [:models, :controllers, :views, :helpers, :lib].each do |sub|
    desc "Run the specs under spec/#{sub}"
    Spec::Rake::SpecTask.new(sub => spec_prereq) do |t|
      t.spec_opts = ['--options', "\"#{PLUGIN_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
    end
  end
end

# TODO: Requires webrat to be installed as a plugin....
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty"
end

namespace :features do
  Cucumber::Rake::Task.new(:rcov) do |t|
    t.cucumber_opts = "--format pretty" 
    t.rcov = true
    t.rcov_opts << ["--rails", "--sort=coverage", "--exclude '/var/lib/gems,spec,#{REDMINE_APP},#{REDMINE_LIB},step_definitions,features/support'"]
  end
end

desc 'Generate documentation for the plugin.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = PROJECT_NAME
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end


