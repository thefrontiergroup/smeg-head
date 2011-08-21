Given /^the current repository has the collaborators:$/ do |table|
  repo = @repository
  table.hashes.each do |hash|
    repo.collaborators << User.make!(hash)
  end
end