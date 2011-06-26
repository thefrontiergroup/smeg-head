Then /^I should see (.*) named "([^"]*)"$/ do |locator, key_name|
  page.should have_css "#{selector_for(locator)}:contains(#{key_name.inspect})"
end

Then /^I should see errors on (.*)$/ do |name|
  page.should have_css "#{field_selector_for(name)} p.inline-errors"
end