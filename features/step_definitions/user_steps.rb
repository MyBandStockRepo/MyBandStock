Given /^an admin user in the system with the email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  role = Role.find_or_create_by_name("site_admin")
  @user = Factory :user, :email => email, :email_confirmation => email, :password => password
  @user.roles << role
  @user.generate_or_salt_password(password)
  @user.save
end
Given /^I am not logged in$/ do
  visit logout_path
end
Given /^I am logged in as admin user "([^"]*)" with password "([^"]*)"$/ do |email, password|
  visit("/login")
  fill_in("email", :with => email)
  fill_in("password", :with => password)
  click_button("login")
end
