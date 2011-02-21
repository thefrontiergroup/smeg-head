desc "Runs the spec tasks, generating coverage"
task :simplecov do
  ENV['COVERAGE'] = 'true'
  Rake::Task["spec"].invoke
end