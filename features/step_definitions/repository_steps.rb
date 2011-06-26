Given /^I am editing the current repository$/ do
  @repository = Repository.last
  Given %{I am on the page for the "#{@repository.clone_path}" repository}
  And   %{I follow "Edit this Repository"}
end

Then /^I should be editing the current repository$/ do
  Then %{I should be on the page for the "#{@repository.clone_path}" repository}
end

Then /^the current repository should no longer exist$/ do
  Repository.where(:id => @repository.id).should be_empty
end