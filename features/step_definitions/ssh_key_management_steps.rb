Given /^the following ssh_key_managements:$/ do |ssh_key_managements|
  SshKeyManagement.create!(ssh_key_managements.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) ssh_key_management$/ do |pos|
  visit ssh_key_managements_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following ssh_key_managements:$/ do |expected_ssh_key_managements_table|
  expected_ssh_key_managements_table.diff!(tableish('table tr', 'td,th'))
end
