Given /^I am not authenticated$/ do
  Given 'I got to sign out'
end

Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  @user = User.make!(:email => email, :password => password, :password_confirmation => password)
end

Given /^I have one\s+user "([^\"]*)" with user name "([^\"]*)" and password "([^\"]*)"$/ do |email, user_name, password|
  @user = User.make!(:email => email, :password => password, :password_confirmation => password, :user_name => user_name)
end

Given /^I sign in as "([^\"]*)" with the password "([^\"]*)"$/ do |email, password|
  Given %{I go to the sign in page}
  And   %{I fill in "User name or Email" with "#{email}"}
  And   %{I fill in "Password" with "#{password}"}
  And   %{I press "Sign In"}
end

Given /^I am a new, authenticated user$/ do
  email, password = Forgery(:internet).email_address, 'password'
  Given %{I have one user "#{email}" with password "#{password}"}
  And   %{I sign in as "#{email}" with the password "#{password}"}
end

Given /^I am a new, authenticated user with the ([^\"]*) "([^\"]*)"$/ do |field, value|
  @user = User.make! recognize_attribute_name(field) => value
  Given %{I sign in as "#{@user.email}" with the password "#{@user.password}"}
end

Given /^I am signed out$/ do
  Given "I go to the sign out page"
end

Then /^I should be signed in$/ do
  visit root_path
  page.should have_css 'ul#repositories'
end

Then /^I should not be signed in$/ do
  Then "I should be signed out"
end

Then /^I should be signed out$/ do
  visit root_path
  page.should_not have_css 'ul#repositories'
end

Then /^my account should no longer exist$/ do
  User.where(:id => @user.id).should be_empty
end