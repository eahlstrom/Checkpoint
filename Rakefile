require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require "rdoc/task"
require "rspec/core/rake_task"

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

desc "run lib specs"
RSpec::Core::RakeTask.new(:spec_lib) do |t|
  t.verbose = false
  t.pattern = 'spec/checkpoint/**/*_spec.rb'
end

desc "run bin specs"
RSpec::Core::RakeTask.new(:spec_bin) do |t|
  t.verbose = false
  t.pattern = 'spec/bin/**/*_spec.rb'
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "checkpoint #{Checkpoint::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

