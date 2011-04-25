require 'fileutils'

desc "Runs the spec tasks, generating coverage"
task :simplecov do
  if RUBY_VERSION < '1.9'
    STDERR.puts 'SimpleCov requires Ruby 1.9 or higher'
    exit 1
  end
  ENV['COVERAGE'] = 'true'
  FileUtils.rm_rf "coverage"
  Rake::Task["spec"].invoke
end