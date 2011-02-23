require 'fileutils'

desc "Runs the spec tasks, generating coverage"
task :simplecov do
  ENV['COVERAGE'] = 'true'
  FileUtils.rm_rf "coverage"
  Rake::Task["spec"].invoke
end