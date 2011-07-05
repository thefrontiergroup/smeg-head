Given /^I have (.+?) with the ([^\"]*) "([^\"]*)"$/ do |name, field, value|
  field  = recognize_attribute_name(field)
  object = recognize_model(name).make field => value
  @user.should_not be_nil
  if object.respond_to? :user=
    object.user = @user
  elsif object.respond_to? :owner=
    object.owner= @user
  end
  object.save!
  store_as_variable! name, object
end

Given /^I have no (.+) with the ([^\"]*) "([^\"]*)"$/ do |name, field, value|
  field = recognize_attribute_name(field)
  @user.should_not be_nil
  recognize_association(@user, name).where(field => value).destroy_all
end

Given /^there are no (.+) with the ([^\"]*) "([^\"]*)"$/ do |name, field, value|
  field = recognize_attribute_name(field)
  recognize_model(name).where(field => value).destroy_all
end

Given /^there is (.+) with the ([^\"]*) "([^\"]*)"$/ do |name, field, value|
  field = recognize_attribute_name(field)
  recognize_model(name).make! field => value
end

Then /^I should have a new (.+) with the ([^\"]*) "([^\"]*)"$/ do |name, field, value|
  field = recognize_attribute_name(field)
  @user.should_not be_nil
  object = recognize_association(@user, name).last
  store_as_variable! name, object
  object.should_not be_nil
  object.send(field).to_s.should == value
end

Then /^my (.+) should be "([^\"]*)"$/ do |field, value|
  @user.should_not be_nil
  field = recognize_attribute_name(field)
  @user.reload
  @user.send(field).to_s.should == value
end

Then /^I should not have an? (.+?) with the ([^\"]*) "([^\"]*)"$/ do |name, field, value|
  field = recognize_attribute_name(field)
  @user.should_not be_nil
  recognize_association(@user, name).where(field => value).should be_empty
end


Then /^the current ([^"]*)'s ([^"]*) should be "([^"]*)"$/ do |name, field, value|
  object = retreive_variable(name)
  if object
    object.reload # Ensure it's a fresh instance.
  else
     object = recognize_model(name).last
  end
  object.should be_present
  object.send(recognize_attribute_name(field)).to_s.should == value
end