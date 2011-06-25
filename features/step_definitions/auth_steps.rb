Given /^I am not authenticated$/ do
  Given 'I got to sign out'
end

Given /^I have one\s+user "([^\"]*)" with login "([^\"]*)"$ and password "([^\"]*)"$/ do |email, login, password|
  @user = User.make!(:email => email, :password => password, :password_confirmation => password, :login => login)
end

Given /^I am a new, authenticated user$/ do
  email, password = Forgery(:internet).email_address, 'password'
  Given %{I have one user "#{email}" with password "#{password}"}
  And   %{I go to sign in}
  And   %{I fill in "user_email" with "#{email}"}
  And   %{I fill in "user_password" with "#{password}"}
  And   %{I press "Sign in"}
end