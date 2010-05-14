# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

#the creation tree goes as follows
#user ->
adminUser = User.create( :first_name => 'admin', 
                        :last_name => 'user', 
                        :password_confirmation => 'fd7013a96f6210e7aa475bed9f422f70ffefa5932e5e05a6aea77840929edce2', 
                        :password => 'fd7013a96f6210e7aa475bed9f422f70ffefa5932e5e05a6aea77840929edce2', 
                        :country_id => 233, 
                        :email => 'mbstech@mybandstock.com', 
                        :status => 'active',
                        :agred_to_tos => true,
                        :agreed_to_pp => true)
                        
site_adminm_role = Role.create(:name => 'site_admin')
Role.create(:name => 'staff')

#grant the admin user site_admin
adminUser.roles << site_admin_role


#create JM's stuff
jm = User.create( :first_name => 'John-Michael',
                  :last_name => 'Fischer',
                  :password => 'test',
                  :password_confirmation => 'test',
                  :country_id => 233,
                  :email => 'jm@mybandstock.com',
                  :status => 'active',
                  :agreed_to_tos => true,
                  :agreed_to_pp => true)
#grant admin
jm.roles << site_admin_role
#create a band
b = Band.create(  :name => 'The Dosimeters',
                  :shortname => 'the_dosimeters',
                  :country_id => 233)
#make me an admin
jm.associations.create(:band_id => b.id, :name => 'admin')



#create Brians stuff
brian = User.create( :first_name => 'Brian',
                  :last_name => 'Jennings',
                  :password => 'test',
                  :password_confirmation => 'test',
                  :country_id => 233,
                  :email => 'brian@mybandstock.com',
                  :status => 'active',
                  :agreed_to_tos => true,
                  :agreed_to_pp => true)

#create Jakes stuff
jake = User.create( :first_name => 'Jake',
                  :last_name => 'Schwartz',
                  :password => 'test',
                  :password_confirmation => 'test',
                  :country_id => 233,
                  :email => 'jake@mybandstock.com',
                  :status => 'active',
                  :agreed_to_tos => true,
                  :agreed_to_pp => true)

