require 'bundler/gem_tasks'
require 'bundler/setup'
require 'bundler'
require 'rake'
require 'rspec/core/rake_task'

Bundler.setup(:default, :test)

desc 'Run the default which is to run the tests'
task :default => :test

desc 'Run the specs'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = %w(specs/**/*spec.rb)
end

desc 'Update the gem version by one value'
task :update_version, :new_version do |t, args|
  abort('No version specified') if not args[:new_version]

  VERSION = /VERSION\s=\s'(?<major>\d*)\.(?<minor>\d*)\.(?<build>\d*)'/
  puts "Updating application to build #{args[:new_version]}"

  version_file = File.dirname(__FILE__) + '/lib/iron-spect/version.rb'
  version_contents = File.read(version_file)

  match = VERSION.match(version_contents)
  return if not match

  new_version = "#{match[:major]}.#{match[:minor]}.#{args[:new_version]}"
  puts "Updating the version to #{new_version}"

  replace = "VERSION = '#{new_version}'"
  new_contents = version_contents.gsub(VERSION, replace)

  File.open(version_file, 'w') do |data|
    data << new_contents
  end
end