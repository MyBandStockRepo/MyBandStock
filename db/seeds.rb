# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)



adminUser = User.create(:first_name => 'admin', :last_name => 'user', :password_confirmation => 'fd7013a96f6210e7aa475bed9f422f70ffefa5932e5e05a6aea77840929edce2', :password => 'fd7013a96f6210e7aa475bed9f422f70ffefa5932e5e05a6aea77840929edce2', :country_id => 233, :email => 'mbstech@mybandstock.com', :status => 'active')
r = User.find(adminUser.id).roles.create(:name => 'site_admin')
roles = Role.create(:name => 'staff')

