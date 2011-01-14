Given /^there is a band in the system named "([^"]*)"$/ do |name|
  Factory :band, :name => name
end
