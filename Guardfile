guard 'rspec', :version => 2, :cli => '--colour --format=Fuubar --fail-fast' do
  watch(/^spec\/(.*)_spec.rb/)
  watch(/^lib\/(.*)\.rb/)                               { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(/^spec\/spec_helper.rb/)                        { "spec" }
  watch(/^spec\/support\/(.*)\.rb/)                     { "spec" }
  watch(/^app\/(.*)\.rb/)                               { |m| "spec/#{m[1]}_spec.rb" }
  watch(/^config\/routes.rb/)                           { "spec/routing" }
  watch(/^app\/controllers\/application_controller.rb/) { "spec/controllers" }
  watch(/^spec\/factories.rb/)                          { "spec/models" }
end

guard 'ego' do
  watch('Guardfile')
end

guard 'pow' do
  watch('.powrc')
  watch('.powenv')
  watch('.rvmrc')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
end

guard 'bundler' do
  watch('Gemfile')
end

guard 'cucumber', :notify => false do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})                      { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end
