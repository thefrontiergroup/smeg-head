guard 'rspec', :version => 2 do
  watch(/^spec\/(.*)_spec.rb/)
  watch(/^lib\/(.*)\.rb/)                               { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(/^spec\/spec_helper.rb/)                        { "spec" }
  watch(/^spec\/support\/(.*)\.rb/)                     { "spec" }
  watch(/^app\/(.*)\.rb/)                               { |m| "spec/#{m[1]}_spec.rb" }
  watch(/^config\/routes.rb/)                           { "spec/routing" }
  watch(/^app\/controllers\/application_controller.rb/) { "spec/controllers" }
  watch(/^spec\/factories.rb/)                          { "spec/models" }
end