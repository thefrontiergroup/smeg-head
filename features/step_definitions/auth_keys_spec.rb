Then /^I should( no longer)? see the current key in my authorized keys file$/ do |negative|
  file = SshPublicKeyManager.authorized_keys_file
  key  = @ssh_public_key
  key.should be_present
  if negative
    file.should_not have_key key.key
  else
    file.should have_key key.key
  end
end